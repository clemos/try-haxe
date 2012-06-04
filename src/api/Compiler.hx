package api;

#if php
import php.Web;
import php.Sys;
import php.Lib;
import php.FileSystem;
import php.io.File;
#end

class Compiler {

	static var tmp = "../tmp";

	public function new(){}

	public static function checkSanity( s : String ){
		var alphaNum = ~/[^a-zA-Z0-9]/;
		if( alphaNum.match(s) ) throw "Unauthorized :" + s + "";
	}

	public function compile( program : Program ){

		while( program.uid == null ){
			var uid = haxe.Md5.encode( Std.string( Math.random() ) +Std.string( Date.now().getTime() ) );
			var tmpDir = tmp + "/" + uid;
			if( !(FileSystem.exists( tmpDir )) ){
				program.uid = uid;
			}
		}

		checkSanity( program.uid );
		checkSanity( program.main.name );

		var tmpDir = tmp + "/" + program.uid;

		if( !FileSystem.isDirectory( tmpDir )){
			FileSystem.createDirectory( tmpDir );
		}

		var mainFile = tmpDir + "/" + program.main.name + ".hx";

		var source = program.main.source;
		source = ~/@([^:]*):([^a-z]*)(macro|build|autoBuild)/.customReplace( source , function( m ){ return ""; } );
		
		File.saveContent( mainFile , source );

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

		var proc = new sys.io.Process( "haxe" , args );
		var exitCode = proc.exitCode();
		var outp = proc.stdout.readAll().toString();
		var err = proc.stderr.readAll().toString();

		var output : Program.Output = if( exitCode == 0 ){
			{
				uid : program.uid,
				args : args,
				stderr : err,
				stdout : outp,
				success : true,
				message : "Build success!",
				href : outputUrl,
				source : File.getContent( outputUrl )
			}
		}else{
			{
				uid : program.uid,
				args : args,
				stderr : err,
				stdout : outp,
				success : false,
				message : "Build failure",
				href : "",
				source : ""
			}
		}
		
		return output;
	}

}