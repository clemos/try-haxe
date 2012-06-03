
#if js
import api.Program;
import haxe.remoting.HttpAsyncConnection;
import js.codemirror.CodeMirror;
import js.JQuery;
#else
import haxe.remoting.HttpConnection;
#end

#if php 
import php.Web;
import php.Lib;
import sys.io.File;
#end

import haxe.remoting.Context;

class App {

	#if js 
	var url : String;
	var cnx : HttpAsyncConnection;
	var form : JQuery;
	var haxeSource : CodeMirror;
	var jsSource : CodeMirror;
	var runner : JQuery;

	var program : Program;
	var output : Output;
	var messages : JQuery;

	var gateway : String;
	
	public static function main(){
		new App();
  	}

  	public function new(){
  		
  		haxeSource = CodeMirror.fromTextArea( cast new JQuery("textarea[name='hx-source']").get(0) , {
			mode : "javascript",
			theme : "cobalt",
			lineWrapping : true,
			lineNumbers : true
		} );
		
		jsSource = CodeMirror.fromTextArea( cast new JQuery("textarea[name='js-source']").get(0) , {
			mode : "javascript",
			theme : "cobalt",
			lineWrapping : true,
			lineNumbers : true,
			readOnly : true
		} );
		
		runner = new JQuery("iframe[name='js-run']");
		messages = new JQuery(".messages");

		new JQuery("a[data-toggle='tab']").bind( "shown", function(e){
			jsSource.refresh();
		});
		
		new JQuery(".compile-btn").bind("click", compile);

		gateway = new JQuery("body").data("gateway");
		cnx = HttpAsyncConnection.urlConnect(gateway);

		program = {
			uid : null,
			main : {
				name : "Test",
				source : haxeSource.getValue()
			},
			target : JS( "test" )
		}
  	}

  	public function compile(?e){
  		if( e != null ) e.preventDefault();
  		program.main.source = haxeSource.getValue();
  		cnx.Compiler.compile.call( [program] , onCompile );
  	}

  	public function run(){
  		if( output.success ){
	  		var run = gateway + "?run=" + output.uid + "&r=" + Std.string(Math.random());
	  		runner.attr("src" , run );
  		}
  	}

  	public function onCompile( o : Output ){

  		var errLine = ~/([^:]*):([0-9]+): characters ([0-9]+)-([0-9]+) :(.*)/g;
  		
  		output = o;
  		program.uid = output.uid;
  		
  		jsSource.setValue( output.source );
  		
  		if( output.success ){
  			messages.html( "<div class='alert alert-success'><h4 class='alert-heading'>" + output.message + "</h4><pre>"+output.stderr+"</pre></div>" );
  		}else{
  			messages.html( "<div class='alert alert-error'><h4 class='alert-heading'>" + output.message + "</h4><pre>"+output.stderr+"</pre></div>" );
  		}

  		run();

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
		    	php.Lib.print("<html><body><script src='//ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js'></script><script>"+File.getContent('../tmp/'+run+'/test.js')+"</script></body></html>");
		    	return;
		    }
		}
  	#end

  	
}