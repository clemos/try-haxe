package api;

#if php
import php.Web;
import php.Sys;
import php.Lib;
import php.FileSystem;
import php.io.File;
#end

using Lambda;

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
			for (i in 0...id.length) uid += if (Math.random() > 0.5 ) id.charAt(i).toUpperCase() else id.charAt(i);

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
		if (uid.length != 5) return null; // simple md5 check
		
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

	public function autocomplete( program : Program , pos : { line : Int, ch : Int } ) : Array<String>{
		
		prepareProgram( program );

		var source = program.main.source;
		var lines = source.split("
");
		var char = 0;

		for( i in 0...pos.line ){
			char += lines[i].length + 1;
		}
		char += pos.ch;

		var args = [
			"-cp" , tmpDir,
			"-main" , program.main.name,
			"-js" , "dummy.js",
			"-v",
			"--display" , tmpDir + "/" + program.main.name + ".hx@" + char
		];

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

	function addLibs(args:Array<String>, program:Program) 
	{
		for (l in program.libs)
		{
			if (l.checked)
			{
				args.push("-lib");
				args.push(l.name);
				if (l.args != null) for (a in l.args) args.push(a);
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
		
		switch( program.target ){
			case JS( name ):
				checkSanity( name );
				outputUrl = tmpDir + "/" + name + ".js";
				args.push( "-js" );
				args.push( outputUrl );
				args.push("--js-modern");
				args.push("-D");
				args.push("noEmbedJS");
				

			case SWF( name , version ):
				checkSanity( name );
				outputUrl = tmpDir + "/" + name + ".swf";
				
				args.push( "-swf" );
				args.push( outputUrl );
				args.push( "-swf-version" );
				args.push( Std.string( version ) );
		}

		addLibs(args, program);
		
		var out = runHaxe( args );

		var output : Program.Output = if( out.exitCode == 0 ){
			{
				uid : program.uid,
				args : args,
				stderr : out.err,
				stdout : out.out,
				success : true,
				message : "Build success!",
				href : outputUrl,
				source : File.getContent( outputUrl )
			}
		}else{
			{
				uid : program.uid,
				args : args,
				stderr : out.err,
				stdout : out.out,
				success : false,
				message : "Build failure",
				href : "",
				source : ""
			}
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