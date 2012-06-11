#if php
import php.Web;
#end

class App {

	#if js 
	public static function main(){
		new Editor();
  	}

  	#else
	  	public static function main(){

	  		var params = Web.getParams();
	  		var url = params.get('_url');
	  		params.remove('_url');

	  		if( params.exists('_root') ){
	  			Api.root = params.get('_root');
	  			Api.base = Api.root + "/app";
	  		}else{
		  		var base :String = untyped __php__("$_SERVER['SCRIPT_NAME']");
		  		var spl = base.split("/");
		  		spl.pop();

		  		Api.base = spl.join("/");
		  		spl.pop();
		  		Api.root = spl.join("/");
	  		}

	  		var api = new Api();

	  		haxe.web.Dispatch.run( url , params , api );   
		}
  	#end

  	
}