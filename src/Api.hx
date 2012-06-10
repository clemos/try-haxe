import haxe.remoting.HttpConnection;
import haxe.remoting.Context;
import sys.io.File;
import sys.FileSystem;
import php.Web;
import php.Lib;
import haxe.web.Dispatch;

class Api {

	var program : api.Program;
	var dir : String;
	public static var base : String;
	public static var root : String;

	public static var tmp = "../tmp";
	
	public function new(){}

	public static function checkSanity( s : String ){
		var alphaNum = ~/[^a-zA-Z0-9]/;
		if( alphaNum.match(s) ) throw "Unauthorized :" + s + "";
	}

	public function doCompiler(){
		var ctx = new Context();
    	ctx.addObject("Compiler",new api.Compiler());
    	if( haxe.remoting.HttpConnection.handleRequest(ctx) )
      		return;
	}

	function notFound(){
		Web.setReturnCode(404);
	}

	public function doProgram( id : String , d : Dispatch ){
		checkSanity( id );
		dir = tmp + "/" + id;
		if( FileSystem.exists( dir ) && FileSystem.isDirectory( dir ) ){
			d.dispatch( {
				doRun : runProgram,
				doGet : getProgram
			} );
		}else{
			notFound();
		}
	}

	public function runProgram( ){
		php.Lib.print(File.getContent(dir+'/index.html'));
	}

	public function getProgram( ){
		php.Lib.print(File.getContent(dir+'/program'));
	}



}