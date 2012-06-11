
import api.Program;
import haxe.remoting.HttpAsyncConnection;
import js.codemirror.CodeMirror;
import js.JQuery;

using js.bootstrap.Button;
using Lambda;
using StringTools;

class Editor {

	var cnx : HttpAsyncConnection;
	
	var program : Program;
	var output : Output;
	
	var gateway : String;
	
	var form : JQuery;
	var haxeSource : CodeMirror;
	var jsSource : CodeMirror;
	var runner : JQuery;
	var messages : JQuery;
	var compileBtn : JQuery;
  var libs : JQuery;
  var targets : JQuery;
  var stage : JQuery;
  var jsTab : JQuery;

  var markers : Array<MarkedText>;
  var lineHandles : Array<LineHandle>;

  var completions : Array<String>;
  var completionIndex : Int;

	public function new(){
    markers = [];
    lineHandles = [];

		CodeMirror.commands.autocomplete = autocomplete;
    CodeMirror.commands.compile = function(_) compile();

  	haxeSource = CodeMirror.fromTextArea( cast new JQuery("textarea[name='hx-source']")[0] , {
			mode : "javascript",
			theme : "default",
			lineWrapping : true,
			lineNumbers : true,
			extraKeys : {
				"Ctrl-Space" : "autocomplete",
        "Ctrl-Enter" : "compile",
        "F8" : "compile",
        "F5" : "compile"
			},
      onChange : onChange
		} );

   
		jsSource = CodeMirror.fromTextArea( cast new JQuery("textarea[name='js-source']")[0] , {
			mode : "javascript",
			theme : "default",
			lineWrapping : true,
			lineNumbers : true,
			readOnly : true
		} );
		
		runner = new JQuery("iframe[name='js-run']");
		messages = new JQuery(".messages");
		compileBtn = new JQuery(".compile-btn");
    libs = new JQuery("#hx-options-form .hx-libs");
    targets = new JQuery("#hx-options-form .hx-targets");
    stage = new JQuery(".js-output .js-canvas");
    jsTab = new JQuery("a[href='#js-source']");

    new JQuery(".link-btn").bind("click", function(e){
      var _this = new JQuery(e.target);
      if( _this.attr('href') == "#" ){
        e.preventDefault();
      }
    });

    new JQuery(".fullscreen-btn").bind("click" , function(e){
      var _this = new JQuery(e.target);
      e.preventDefault();
      if( _this.attr('href') != "#" ){
        var r = this.runner;
        this.runner.attr('src', _this.attr('href'));
        untyped __js__("el = r.get(0)
            , rfs = el.requestFullScreen
                || el.webkitRequestFullScreen
                || el.mozRequestFullScreen
        ;
        rfs.call(el);");
      }
    });
      
		new JQuery("body").bind("keyup", onKey );

		new JQuery("a[data-toggle='tab']").bind( "shown", function(e){
			jsSource.refresh();
      haxeSource.refresh();
		});

    targets.delegate("input[name='target']" , "change" , onTarget );
		
		compileBtn.bind( "click" , compile );

		var apiRoot = new JQuery("body").data("api");
		cnx = HttpAsyncConnection.urlConnect(apiRoot+"/compiler");

    program = {
      uid : null,
      main : {
        name : "Test",
        source : haxeSource.getValue()
      },
      target : SWF( "test", 11 ),
      libs : new Array()
    };

    initLibs();

    setTarget( api.Program.Target.JS( "test" ) );

		var uid = js.Lib.window.location.hash;
		if (uid.length > 0){
      uid = uid.substr(1);
  		cnx.Compiler.getProgram.call([uid], onProgram);
    }
  }

  function onTarget(e : JqEvent){
    var cb = new JQuery( e.target );
    var name = cb.val();
    var target = switch( name ){
      case "swf" : api.Program.Target.SWF('test',11);
      case "js" : api.Program.Target.JS('test');
    }
    setTarget(target);
  }

  function setTarget( target : api.Program.Target ){
    program.target = target;
    libs.find(".controls").hide();
    
    var sel :String;
    
    switch( target ){
      case JS(_): 
        sel = "js";
        jsTab.fadeIn();

      case SWF(_,_) : 
        sel = "swf";
        jsTab.hide();
    }

    var radio = new JQuery( "input[name='target'][value='" + sel +"']" );
    radio.attr( 'checked' ,'checked' );

    libs.find("."+sel+"-libs").fadeIn();
  }

  function initLibs(){
    for( t in ["swf","js"] ){
      var el = libs.find("."+t+"-libs");
      var libs : Array<Libs.LibConf> = Reflect.field( Libs.available , t );
      for( l in libs ){

        el.append(
          '<label class="checkbox"><input class="lib" type="checkbox" value="' + l.name + '" ' 
          + ((Libs.defaultChecked.has(l.name) /*|| selectedLib(l.name)*/) ? "checked='checked'" : "") 
          + '" /> ' + l.name 
          + "<span class='help-inline'><a href='" + (l.swf == null ? "http://lib.haxe.org/p/" + l.name : l.swf.help) 
          +"' target='_blank'><i class='icon-question-sign'></i></a></span>"
          + "</label>"
          );
    
      }
    }
  }

	//function onProgram(p:{p:Program, o:Output})
  function onProgram(p:Program)
	{
		//trace(p);
		if (p != null)
		{
			// sharing
			//program = p.p;
      program = p;

      // auto-fork
      program.uid = null;

			haxeSource.setValue(program.main.source);
      setTarget( program.target );

      if( program.libs != null ){
        for( lib in libs.find("input.lib") ){
          if( program.libs.has( lib.val() ) ){
            lib.attr("checked","checked");
          }else{
            lib.removeAttr("checked");
          }
        }
      }

      //if (p.o != null) onCompile(p.o);
     
		}

	}

	public function autocomplete( cm : CodeMirror ){
		updateProgram();
    var src = cm.getValue();

    var idx = SourceTools.getAutocompleteIndex( src , cm.getCursor() );
    if( idx == null ) return;

    if( idx == completionIndex ){
      displayCompletions( cm , completions ); 
      return;
    }
    completionIndex = idx;
    if( src.length > 1000 ){
      program.main.source = src.substring( 0 , completionIndex+1 );
    }
    cnx.Compiler.autocomplete.call( [ program , idx ] , function( comps ) displayCompletions( cm , comps ) );
	}

  function showHint( cm : CodeMirror ){
    var src = cm.getValue();
    var cursor = cm.getCursor();
    var from = SourceTools.indexToPos( src , SourceTools.getAutocompleteIndex( src, cursor ) );
    var to = cm.getCursor();

    var token = src.substring( SourceTools.posToIndex( src, from ) , SourceTools.posToIndex( src, to ) );

    var list = [];

    for( c in completions ){
      if( c.toLowerCase().startsWith( token.toLowerCase() ) ){
        list.push( c );
      }
    }

    return {
        list : list,
        from : from,
        to : to
    };
  }

	public function displayCompletions(cm : CodeMirror , comps : Array<String> ) {
		completions = comps;
    CodeMirror.simpleHint( cm , showHint );
	}

  public function onKey( e : JqEvent ){

   if( ( e.ctrlKey && e.keyCode == 13 ) || e.keyCode == 119 ){ // Ctrl+Enter and F8
      e.preventDefault();
      compile(e);
   }
   
  }

	public function onChange( cm :CodeMirror, e : js.codemirror.CodeMirror.ChangeEvent ){
    var txt :String = e.text[0];
    if( txt.trim().endsWith( ".") ){
      autocomplete( haxeSource );
    }
	}

	public function compile(?e){
		if( e != null ) e.preventDefault();
    messages.fadeOut(0);
    clearErrors();
		compileBtn.buttonLoading();
		updateProgram();
		cnx.Compiler.compile.call( [program] , onCompile );
	}

	function updateProgram(){
		program.main.source = haxeSource.getValue();

		var libs = new Array();
    var sel = switch( program.target ){
      case JS(_): "js";
      case SWF(_,_) : "swf";
    }
		var inputs = new JQuery("#hx-options .hx-libs ."+sel+"-libs input.lib:checked");
		// TODO: change libs array only then need
		for (i in inputs)  // refill libs array, only checked libs
		{
			//var l:api.Program.Library = { name:i.attr("value"), checked:true };
			//var d = Std.string(i.data("args"));
			//if (d.length > 0) l.args = d.split("~");
			libs.push(i.val());
		}

		program.libs = libs;
	}

	public function run(){
		if( output.success ){
  		var run = output.href ;
  		runner.attr("src" , run + "?r=" + Std.string(Math.random()) );
      new JQuery(".link-btn, .fullscreen-btn")
        .buttonReset()
        .attr("href" , run + "?r=" + Std.string(Math.random()) );

		}else{
			runner.attr("src" , "about:blank" );
      new JQuery(".link-btn, .fullscreen-btn")
        .addClass("disabled")
        .attr("href" , "#" );
		}
	}

	public function onCompile( o : Output ){

		output = o;
		program.uid = output.uid;
    js.Lib.window.location.hash = "#" + output.uid;
		
		jsSource.setValue( output.source );

    var jsSourceElem = new JQuery(jsSource.getWrapperElement());
		var msg : String = "";
    var msgType : String = "";

		if( output.success ){
      msgType = "success";
			jsSourceElem.show();
      jsSource.refresh();
      stage.show();
      
      //var ifr=$('.js-run').get(0); console.log(ifr);var rfs = ifr.requestFullScreen || ifr.webkitRequestFullScreen || ifr.mozRequestFullScreen; rfs.call(ifr)  
      switch( program.target ){
        case JS(_) : jsTab.show();
        default : jsTab.hide();
      }
		}else{
      msg = output.stderr.replace("\n","<br/>");
      msgType = "error";
      stage.hide();
      jsTab.hide();
      jsSourceElem.hide();
      markErrors();
		}

    messages.html( "<div class='alert alert-"+msgType+"'><h4 class='alert-heading'>" + output.message + "</h4>"+msg+"</div>" );

    if( output.success && output.stderr != null ){
      messages.append( "<pre>"+output.stderr +"</pre>");
      
    }

    messages.fadeIn();
		compileBtn.buttonReset();

		run();

	}

  public function clearErrors(){
    for( m in markers ){
      m.clear();
    }
    markers = [];
    for( l in lineHandles ){
      haxeSource.clearMarker( l );
    }
  }

  public function markErrors(){
    var errLine = ~/([^:]*):([0-9]+): characters ([0-9]+)-([0-9]+) :(.*)/g;
    
    for( e in output.errors ){
      if( errLine.match( e ) ){
        var err = {
          file : errLine.matched(1),
          line : Std.parseInt(errLine.matched(2)) - 1,
          from : Std.parseInt(errLine.matched(3)),
          to : Std.parseInt(errLine.matched(4)),
          msg : errLine.matched(5)
        };
        if( StringTools.trim( err.file ) == "Test.hx" ){
          //trace(err.line);
          var l = haxeSource.setMarker( err.line , "<i class='icon-warning-sign icon-white'></i>" , "error");
          lineHandles.push( l );

          var m = haxeSource.markText( { line : err.line , ch : err.from } , { line : err.line , ch : err.to } , "error");
          markers.push( m );
        }
        
      }
    }
  }

}