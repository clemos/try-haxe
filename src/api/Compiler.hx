package api;

#if php
import api.Completion.CompletionResult;
import api.Completion.CompletionType;
import php.Web;
import Sys;
import php.Lib;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;
using Lambda;

typedef HTMLConf = 
{
	head:Array<String>,
	body:Array<String>
}

class Compiler {

	var tmpDir : String;
	var mainFile : String;
	public static var haxePath = "haxe";

	public function new(){}

	static function checkMacros( s : String ){
		var forbidden = [
			~/@([^:]*):([\/*a-zA-Z\s]*)(macro|build|autoBuild|file|audio|bitmap|font)/,
			~/macro/
		];
		for( f in forbidden ) if( f.match( s ) ) throw "Unauthorized macro : "+f.matched(0)+"";  
	}

	public function prepareProgram( program : Program ){

		while( program.uid == null ){

			var id = haxe.crypto.Md5.encode( Std.string( Math.random() ) +Std.string( Date.now().getTime() ) );
			id = id.substr(0, 5);
			var uid = "";
			for (i in 0...id.length) uid += if (Math.random() > 0.5) id.charAt(i).toUpperCase() else id.charAt(i);

			var tmpDir = Api.tmp + '/$uid/';
			if( !(FileSystem.exists( tmpDir )) ){
				program.uid = uid;
			}
		}

		Api.checkSanity( program.uid );
		Api.checkSanity( program.main.name );
		Api.checkDCE( program.dce );

		tmpDir = Api.tmp + "/" + program.uid + "/";

		if( !FileSystem.isDirectory( tmpDir )){
			FileSystem.createDirectory( tmpDir );
		}

		mainFile = tmpDir + program.main.name + ".hx";

		var source = program.main.source;
		checkMacros( source );
		
		File.saveContent( mainFile , source );

		var s = program.main.source;
		program.main.source = null;
		File.saveContent( tmpDir + "program", haxe.Serializer.run(program));
		program.main.source = s;

	}

	//public function getProgram(uid:String):{p:Program, o:Program.Output} 
	public function getProgram(uid:String):Program
	{
		Api.checkSanity(uid);
		
		if (FileSystem.isDirectory( Api.tmp + "/" + uid ))
		{
			tmpDir = Api.tmp + "/" + uid + "/";

			var s = File.getContent(tmpDir + "program"); 
			var p:Program = haxe.Unserializer.run(s);

			mainFile = tmpDir + p.main.name + ".hx";

			p.main.source = File.getContent(mainFile);

			/*
			var o:Program.Output = null;

			var htmlPath : String = tmpDir + "/" + "index.html";

			if (FileSystem.exists(htmlPath))
			{
				var runUrl = Api.base + "/program/"+p.uid+"/run";
				o = {
					uid : p.uid,
					stderr : null,
					stdout : "",
					args : [],
					errors : [],
					success : true,
					message : "Build success!",
					href : runUrl,
					source : ""
				}

				switch (p.target) {
					case JS(name):
					var outputPath = tmpDir + "/" + name + ".js";
					o.source = File.getContent(outputPath);
					default:
				}
			}
			*/
			//return {p:p, o:o};
			return p;
		}

		return null;
	}

	// TODO: topLevel competion
	public function autocomplete( program : Program , idx : Int ) : CompletionResult{
		
		try{
			prepareProgram( program );
		}catch(err:String){
			return {};
		}

		var source = program.main.source;
		var display = tmpDir + program.main.name + ".hx@" + idx;

		var args = [
			"-cp" , tmpDir,
			"-main" , program.main.name,
			"-v",
			"--display" , display
		];

		switch (program.target) {
			case JS(_):
				args.push("-js");
				args.push("dummy.js");

			case SWF(_, version):
				args.push("-swf");
				args.push("dummy.swf");
				args.push("-swf-version");
				args.push(Std.string(version));
		}

		addLibs(args, program);

		var out = runHaxe( args );

		try{
			var xml = new haxe.xml.Fast( Xml.parse( out.err ).firstChild() );
			
			if (xml.name == "type") {
				var res = xml.innerData.trim().htmlUnescape();
				res = res.replace(" ->", ",");
				if (res == "Dynamic") res = ""; // empty enum ctor completion
				var pos = res.lastIndexOf(","); // result type
				res = if (pos != -1) res.substr(0, pos) else "";
				if (res == "Void") res = ""; // no args methods

				return {type:res};
			}

			var words = [];
			for( e in xml.nodes.i ){
				var w = e.att.n;
				if( !words.has( w ) )
					words.push( w );

			}
			return {list:words};

		}catch(e:Dynamic){
			
		}

		return {errors:SourceTools.splitLines(out.err.replace(tmpDir, ""))};
		
	}

	function addLibs(args:Array<String>, program:Program, ?html:HTMLConf) 
	{
		var availableLibs = Libs.getLibsConfig(program.target);
		for( l in availableLibs ){
			if( program.libs.has( l.name ) ){
				if (html != null)
				{
					if (l.head != null) html.head = html.head.concat(l.head);
					if (l.body != null) html.body = html.body.concat(l.body);
				}
				if (l.swf != null)
				{
					args.push("-swf-lib");
					args.push("../../lib/swf/" + l.swf.src);
				}
				else
				{
					args.push("-lib");
					args.push(l.name);
				}
				if( l.args != null ) 
					for( a in l.args ){
						args.push(a);
					}
			}
		}
		
	}

	public function compile( program : Program ){
		try{
			prepareProgram( program );
		}catch(err:String){
			return {
				uid : program.uid,
				args : [],
				stderr : err,
				stdout : "",
				errors : [err],
				success : false,
				message : "Build failure",
				href : "",
				source : "",
				embed : ""
			}
		}

		var args = [
			"-cp" , tmpDir,
			"-main" , program.main.name,
			"--times",
			"-dce", program.dce
			//"--dead-code-elimination"
		];

		var outputPath : String;
		var htmlPath : String = tmpDir + "index.html";
		var runUrl = '${Api.base}/program/${program.uid}/run';
		var embedSrc = '<iframe src="http://${Api.host}${Api.base}/embed/${program.uid}" width="100%" height="300" frameborder="no" allowfullscreen>
	<a href="http://${Api.host}/#${program.uid}">Try Haxe !</a>
</iframe>';
		
		var html:HTMLConf = {head:[], body:[]};

		switch( program.target ){
			case JS( name ):
				Api.checkSanity( name );
				outputPath = tmpDir + name + ".js";
				args.push( "-js" );
				args.push( outputPath );
				html.body.push("<script src='//ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js'></script>");
				html.body.push("<script src='//markknol.github.io/console-log-viewer/console-log-viewer.js'></script>");
				html.body.push("<style type='text/css'>
					#debug_console {
						background:#fff;
						font-size:14px;
					}
					#debug_console font.log-normal {
						color:#000;
					}
					#debug_console a.log-button  {
						display:none;
					}
					</style>");
				

			case SWF( name , version ):
				Api.checkSanity( name );
				outputPath = tmpDir + name + ".swf";
				
				args.push( "-swf" );
				args.push( outputPath );
				args.push( "-swf-version" );
				args.push( Std.string( version ) );
				args.push("-debug");
				args.push("-D");
				args.push("advanced-telemetry"); // for Scout
				html.head.push("<link rel='stylesheet' href='"+Api.root+"/swf.css' type='text/css'/>");
				html.head.push("<script src='"+Api.root+"/lib/swfobject.js'></script>");
				html.head.push('<script type="text/javascript">swfobject.embedSWF("'+Api.base+"/"+outputPath+'?r='+Math.random()+'", "flashContent", "100%", "100%", "'+version+'.0.0" , null , {} , {wmode:"direct", scale:"noscale"})</script>');
				html.body.push('<div id="flashContent"><p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" /></a></p></div>');
		}

		addLibs(args, program, html);
		//trace(args);
		
		var out = runHaxe( args );
		var err = out.err.replace(tmpDir, "");
		var errors = SourceTools.splitLines(err);

		var output : Program.Output = if( out.exitCode == 0 ){
			{
				uid : program.uid,
				stderr : err,
				stdout : out.out,
				args : args,
				errors : [],
				success : true,
				message : "Build success!",
				href : runUrl,
				embed : embedSrc,
				source : ""
			}
		}else{
			{
				uid : program.uid,
				stderr : err,
				stdout : out.out,
				args : args,
				errors : errors,
				success : false,
				message : "Build failure",
				href : "",
				embed : "",
				source : ""
			}
		}

		if (out.exitCode == 0)
		{
			switch (program.target) {
				case JS(_): 
					output.source = File.getContent(outputPath);
					html.body.push("<script>" + output.source + "</script>");
				default:
			}
			var h = new StringBuf();
			h.add("<html>\n\t<head>\n\t\t<title>Haxe Run</title>");
			for (i in html.head) { h.add("\n\t\t"); h.add(i); }
			h.add("\n\t</head>\n\t<body>");
			for (i in html.body) { h.add("\n\t\t"); h.add(i); } 
			h.add('\n\t</body>\n</html>');

			File.saveContent(htmlPath, h.toString());
		}
		else
		{
			if (FileSystem.exists(htmlPath)) FileSystem.deleteFile(htmlPath);
		}
		
		return output;
	}

	function runHaxe( args : Array<String> ){
		
		var proc = new sys.io.Process( haxePath , args );
		
		var exit = proc.exitCode();
		var out = proc.stdout.readAll().toString();
		var err = proc.stderr.readAll().toString();
		
		var o = {
			proc : proc,
			exitCode : exit,
			out : out,
			err : err
		};

		return o;

	}

}
