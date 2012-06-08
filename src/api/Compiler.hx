package api;

#if php
import php.Web;
import php.Sys;
import php.Lib;
import php.FileSystem;
import php.io.File;
#end

using Lambda;

typedef HTMLConf = 
{
	head:Array<String>,
	body:Array<String>
}

class Compiler {

	static var tmp = "../tmp";

	var tmpDir : String;
	var mainFile : String;

	public function new(){}

	static function checkSanity( s : String ){
		var alphaNum = ~/[^a-zA-Z0-9]/;
		if( alphaNum.match(s) ) throw "Unauthorized :" + s + "";
	}

	function prepareProgram( program : Program ){
		while( program.uid == null ){

			var id = haxe.Md5.encode( Std.string( Math.random() ) +Std.string( Date.now().getTime() ) );
			id = id.substr(0, 5);
			var uid = "";
			for (i in 0...id.length) uid += if (Math.random() > 0.5) id.charAt(i).toUpperCase() else id.charAt(i);

			var tmpDir = tmp + "/" + uid;
			if( !(FileSystem.exists( tmpDir )) ){
				program.uid = uid;
			}
		}

		checkSanity( program.uid );
		checkSanity( program.main.name );

		tmpDir = tmp + "/" + program.uid;

		if( !FileSystem.isDirectory( tmpDir )){
			FileSystem.createDirectory( tmpDir );
		}

		mainFile = tmpDir + "/" + program.main.name + ".hx";

		var source = program.main.source;
		source = ~/@([^:]*):([^a-z]*)(macro|build|autoBuild)/.customReplace( source , function( m ){ return ""; } );
		
		File.saveContent( mainFile , source );

		var s = program.main.source;
		program.main.source = null;
		File.saveContent( tmpDir + "/program", haxe.Serializer.run(program));
		program.main.source = s;

	}

	public function getProgram(uid:String):Program 
	{
		checkSanity(uid);
		
		if (FileSystem.isDirectory( tmp + "/" + uid ))
		{
			tmpDir = tmp + "/" + uid;

			var s = File.getContent(tmpDir + "/program"); 
			var p:Program = haxe.Unserializer.run(s);

			mainFile = tmpDir + "/" + p.main.name + ".hx";

			p.main.source = File.getContent(mainFile);

			return p;
		}

		return null;
	}

	public function autocomplete( program : Program , idx : Int ) : Array<String>{
		
		prepareProgram( program );

		var source = program.main.source;
		
		var args = [
			"-cp" , tmpDir,
			"-main" , program.main.name,
			"-v",
			"--display" , tmpDir + "/" + program.main.name + ".hx@" + idx
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
			var words = [];

			for( e in xml.nodes.i ){
				var w = e.att.n;
				if( !words.has( w ) )
					words.push( w );

			}
			return words;

		}catch(e:Dynamic){
			return [];
		}

		return [];
		
	}

	function addLibs(args:Array<String>, program:Program, ?html:HTMLConf) 
	{
		var availableLibs = switch( program.target ){
			case JS(_) : Libs.available.js;
			case SWF(_,_) : Libs.available.swf;
		}
		for( l in availableLibs ){
			if( program.libs.has( l.name ) ){
				if (html != null)
				{
					if (l.head != null) html.head = html.head.concat(l.head);
					if (l.body != null) html.body = html.body.concat(l.body);
				}
				args.push("-lib");
				args.push(l.name);
				if( l.args != null ) 
					for( a in l.args ){
						args.push(a);
					}
			}
		}
		
	}

	public function compile( program : Program ){

		prepareProgram( program );

		var args = [
			"-cp" , tmpDir,
			"-main" , program.main.name,
			"--times",
			"--dead-code-elimination",
		];

		var outputUrl : String;
		var htmlUrl : String = tmpDir + "/" + "index.html";
		
		var html:HTMLConf = {head:[], body:[]};

		switch( program.target ){
			case JS( name ):
				checkSanity( name );
				outputUrl = tmpDir + "/" + name + ".js";
				args.push( "-js" );
				args.push( outputUrl );
				args.push("--js-modern");
				args.push("-D");
				args.push("noEmbedJS");
				html.body.push("<script src='//ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js'></script>");
				
				

			case SWF( name , version ):
				checkSanity( name );
				outputUrl = tmpDir + "/" + name + ".swf";
				
				args.push( "-swf" );
				args.push( outputUrl );
				args.push( "-swf-version" );
				args.push( Std.string( version ) );
				args.push("-debug");
				html.head.push("<link rel='stylesheet' href='../swf.css' type='text/css'/>");
				html.head.push("<script src='../lib/swfobject.js'></script>");
				html.head.push('<script type="text/javascript">swfobject.embedSWF("'+outputUrl+'", "flashContent", "100%", "100%", "'+version+'.0.0" , null , {} , {wmode:"direct", scale:"noscale"})</script>');
				html.body.push('<div id="flashContent"></div>');
		}

		addLibs(args, program, html);
		
		var out = runHaxe( args );
		var err = out.err.split( tmpDir + "/" ).join("");
		var errors = err.split("
");

		var output : Program.Output = if( out.exitCode == 0 ){
			{
				uid : program.uid,
				args : args,
				stderr : err,
				stdout : out.out,
				errors : [],
				success : true,
				message : "Build success!",
				href : htmlUrl,
				source : ""
			}
		}else{
			{
				uid : program.uid,
				args : args,
				stderr : err,
				stdout : out.out,
				errors : errors,
				success : false,
				message : "Build failure",
				href : "",
				source : ""
			}
		}

		if (out.exitCode == 0)
		{
			switch (program.target) {
				case JS(_): 
					output.source = File.getContent(outputUrl);
					html.body.push("<script>" + output.source + "</script>");
				default:
			}
			var h = new StringBuf();
			h.add("<html>\n\t<head>\n\t\t<title>Haxe/JS Runner</title>");
			for (i in html.head) { h.add("\n\t\t"); h.add(i); }
			h.add("\n\t</head>\n\t<body>");
			for (i in html.body) { h.add("\n\t\t"); h.add(i); } 
			h.add('\n\t</body>\n</html>');

			File.saveContent(htmlUrl, h.toString());
		}
		
		return output;
	}

	function runHaxe( args ){
		var proc = new sys.io.Process( "haxe" , args );
		return {
			proc : proc,
			exitCode : proc.exitCode(),
			out : proc.stdout.readAll().toString(),
			err : proc.stderr.readAll().toString()
		}

	}

}