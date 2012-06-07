
#if !js
import haxe.remoting.HttpConnection;
import haxe.remoting.Context;
import sys.io.File;
#end

#if php 
import php.Web;
import php.Lib;
#end

class App {

	#if js 
	
	public static function main(){
		new Editor();
  	}

  	#else
	  	public static function main(){
	  		var ctx = new Context();
		    	ctx.addObject("Compiler",new api.Compiler());
		    	if( haxe.remoting.HttpConnection.handleRequest(ctx) )
		      		return;

		    var params = Web.getParams();
		    var run = params.get('run');
		    if( run != null ){
		    	php.Lib.print(File.getContent('../tmp/'+run+'/index.html'));
		    	return;
		    }
		}
  	#end

  	
}