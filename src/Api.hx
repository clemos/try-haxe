import haxe.remoting.HttpConnection;
import haxe.remoting.Context;
import sys.io.File;
import sys.FileSystem;
import php.Web;
import php.Lib;
import haxe.web.Dispatch;

using StringTools;

class Api {

	var program : api.Program;
	var dir : String;
	public static var base : String;
	public static var root : String;

	public static var tmp = "../tmp";
	
	public function new(){}

	public static function checkSanity( s : String ){
		var alphaNum = ~/[^a-zA-Z0-9]/;
		if( alphaNum.match(s) ) throw 'Unauthorized :$s';
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
		dir = '$tmp/$id';
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
		php.Lib.print(File.getContent('$dir/index.html'));
	}

	public function getProgram( ){
		php.Lib.print(File.getContent('$dir/program'));
	}

	public function doLoad( d : Dispatch ) {
		var url = d.params.get('url');
		if( url == null ){
			throw "Url required";
		}
		var uid = 'u'+haxe.crypto.Md5.encode(url);
		var compiler = new api.Compiler();

		var program : api.Program = compiler.getProgram(uid);

		if ( program == null ) {
			var req = new haxe.Http( url );
			req.addHeader("User-Agent","try.haxe.org (Haxe/PHP)");
			req.addHeader("Accept","*/*");
			req.onError = function(m){
				throw m;
			}
			req.onData = function(src){
				var program : api.Program = {
			      uid : uid,
			      main : {
			        name : "Test",
			        source : src
			      },
			      target : SWF( "test", 11.4 ),
			      libs : new Array()
				}
				
				compiler.prepareProgram( program );

				redirectToProgram( program.uid );

			}

			req.request(false);

		} else {
			redirectToProgram( program.uid );
		}
	}

	function redirectToProgram( uid : String ) {
		var tpl = '../redirect.html';
		var redirect = File.getContent(tpl);

		redirect = redirect.replace('__url__','/#' + uid );
		php.Lib.print( redirect );
	}



}