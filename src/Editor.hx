import api.Completion.CompletionResult;
import api.Completion.CompletionType;
import api.Program;
import haxe.remoting.HttpAsyncConnection;
import js.Browser;
import js.codemirror.*;
import js.JQuery;
import js.Lib;

using js.bootstrap.Button;
using Lambda;
using StringTools;
using haxe.EnumTools;

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
  var mainName : JQuery;
  var dceName : JQuery;
  var stage : JQuery;
  var jsTab : JQuery;
  var embedTab : JQuery;
  var embedSource : CodeMirror;
  var embedPreview : JQuery;

  var markers : Array<CodeMirror.MarkedText>;
  var lineHandles : Array<CodeMirror.LineHandle>;

  var completions : Array<String>;
  var completionIndex : Int;

	public function new(){
        
    markers = [];
    lineHandles = [];

		//CodeMirror.commands.autocomplete = autocomplete;
    CodeMirror.commands.compile = function(_) compile();
    CodeMirror.commands.togglefullscreen = toggleFullscreenSource;
        
    HaxeLint.load();
        
  	haxeSource = CodeMirror.fromTextArea( cast new JQuery("textarea[name='hx-source']")[0] , {
			mode : "haxe",
			//theme : "default",
			lineWrapping : true,
			lineNumbers : true,
			extraKeys : {
				"Ctrl-Space" : function (cm:CodeMirror) {autocomplete(cm);},
        "Ctrl-Enter" : "compile",
        "F8" : "compile",
        "F5" : "compile",
        "F11" : "togglefullscreen"
			}
        	,
            lint: true,
            matchBrackets: true,
            autoCloseBrackets: true,
            gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter", "CodeMirror-lint-markers"],
            indentUnit: 4,
            tabSize: 4,
            keyMap: "sublime"
		} );

    ColorPreview.create(haxeSource);
        
    haxeSource.on("cursorActivity", function()
    {
        ColorPreview.update(haxeSource);             
    });  
      
    haxeSource.on("scroll", function ()
    {
        ColorPreview.scroll(haxeSource);
    });   
        
    Completion.registerHelper();
    haxeSource.on("change", onChange);
   
		jsSource = CodeMirror.fromTextArea( cast new JQuery("textarea[name='js-source']")[0] , {
			mode : "javascript",
			//theme : "default",
			lineWrapping : true,
			lineNumbers : true,
			readOnly : true
		} );

    embedSource = CodeMirror.fromTextArea( cast new JQuery("textarea[name='embed-source']")[0] , {
      mode : "htmlmixed",
      lineWrapping : true,
      readonly : true
    });
		
		runner = new JQuery("iframe[name='js-run']");
		messages = new JQuery(".messages");
		compileBtn = new JQuery(".compile-btn");
    libs = new JQuery("#hx-options-form .hx-libs");
    targets = new JQuery("#hx-options-form .hx-targets");
    stage = new JQuery(".js-output .js-canvas");
    jsTab = new JQuery("a[href='#js-source']");
    embedTab = new JQuery("a[href='#embed-source']");
    embedPreview = new JQuery("#embed-preview");
    mainName = new JQuery("#hx-options-form input[name='main']");
    dceName = new JQuery("#hx-options-form .hx-dce-name");

    jsTab.hide();
    embedTab.hide();

    new JQuery(".link-btn").bind("click", function(e){
      var _this = new JQuery(e.target);
      if( _this.attr('href') == "#" ){
        e.preventDefault();
      }
    });

    new JQuery(".fullscreen-btn").bind("click" , toggleFullscreenRunner);
    new JQuery("#hx-example-select").bind("change" , toggleExampleChange);
      
		new JQuery("body").bind("keyup", onKey );

		new JQuery("a[data-toggle='tab']").bind( "shown", function(e){
			jsSource.refresh();
      haxeSource.refresh();
      embedSource.refresh();
		});

    dceName.delegate("input[name='dce']" , "change" , onDce );
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
      dce : "full",
      target : SWF( "test", 11.4 ),
      libs : new Array()
    };

    initLibs();

    setTarget( api.Program.Target.JS( "test" ) );

		var uid = Browser.window.location.hash;
		if (uid.length > 0){
      uid = uid.substr(1);
  		cnx.Compiler.getProgram.call([uid], onProgram);
    }
  }
  
  function  onDce(e : JqEvent){
    var cb = new JQuery( e.target );
    var name = cb.val();
    switch( name ){
      case "no", "full", "std": 
        setDCE(name);
      default: 
    }
  }
  
  function setDCE(dce:String) 
  {
	  program.dce = dce;
	  var radio = new JQuery( 'input[name=\'dce\'][value=\'$dce\']' );
	  radio.attr( "checked" ,"checked" );
  }
  
  function toggleExampleChange(e : JqEvent) {
    var _this = new JQuery(e.target);
	var ajax = untyped __js__("$.ajax");
	ajax({
		url:'examples/Example-${_this.val()}.hx',
		dataType: "text"
	}).done(function(data) {
		haxeSource.setValue(data);
	});
  }

  function fullscreen(){
     untyped __js__("var el = window.document.documentElement;
            var rfs = el.requestFullScreen
                || el.webkitRequestFullScreen
                || el.mozRequestFullScreen;
              rfs.call(el); ");
    
  }

  function toggleFullscreenRunner(e : JqEvent){
    var _this = new JQuery(e.target);
    e.preventDefault();
    if( _this.attr('href') != "#" ){
      new JQuery("body").addClass("fullscreen-runner");
      fullscreen();
    }
  }

  function toggleFullscreenSource(_){
    new JQuery("body").toggleClass("fullscreen-source");
    haxeSource.refresh();
    fullscreen();
  }

  function onTarget(e : JqEvent){
    var cb = new JQuery( e.target );
    var name = cb.val();
    var target = switch( name ){
      case "SWF" : 
        api.Program.Target.SWF('test',11.4);
      case _ : 
        api.Program.Target.JS('test');
    }
     
   	if (name == "SWF")
    {
      new JQuery("#output").click();
    }
      
    setTarget(target);
  }

  function setTarget( target : api.Program.Target ){
    program.target = target;
    libs.find(".controls").hide();
    
    var sel :String = Type.enumConstructor(target);
    
    switch( target ){
      case JS(_): 
        //jsTab.fadeIn();

      case SWF(_,_) : 
        jsTab.hide();
    }

    var radio = new JQuery( 'input[name=\'target\'][value=\'$sel\']' );
    radio.attr( "checked" ,"checked" );

    libs.find("."+sel+"-libs").fadeIn();
  }

  function initLibs(){
    for( t in Type.getEnumConstructs(api.Program.Target) ){
      var el = libs.find("."+t+"-libs");
      var libs : Array<Libs.LibConf> = Libs.getLibsConfig(t);
      var def : Array<String> = Libs.getDefaultLibs(t);
	  if (def == null) def = [];
      for( l in libs ){

        el.append(
            '<label class="checkbox"><input class="lib" type="checkbox" value="${l.name}"' 
          + (Lambda.has(def, l.name) ? "checked='checked'" : "") 
          + ' /> ${l.name}'
          + "<span class='help-inline'><a href='" + (l.help == null ? "http://lib.haxe.org/p/" + l.name : l.help) 
          + "' target='_blank'><i class='icon-question-sign'></i></a></span>"
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
      setDCE(program.dce);

      if( program.libs != null ){
        for( lib in libs.find("input.lib") ){
          if( program.libs.has( lib.val() ) ){
            lib.attr("checked","checked");
          }else{
            lib.removeAttr("checked");
          }
        }
      }

      mainName.val(program.main.name);

      //if (p.o != null) onCompile(p.o);
     
		}

	}

	public function autocomplete( cm : CodeMirror ){
    clearErrors();
    messages.fadeOut(0);
		updateProgram();
    var src = cm.getValue();

    var completion = CompletionType.DEFAULT;

    var idx = SourceTools.getAutocompleteIndex( src , cm.getCursor() );
    if( idx == null ) {
      return ;
      // TODO: topLevel completion?
      //idx = SourceTools.posToIndex(src, cm.getCursor());
    }

    // sometimes show incorrect result (time.getDate| change to value.length| -> completionIndex are equals)
    // if( idx == completionIndex && completions != null ){ 
    //   displayCompletions( cm , {list:completions} ); 
    //   return;
    // }
    completionIndex = idx;
    if( src.length > 1000 ){
      program.main.source = src.substring( 0 , completionIndex+1 );
    }
	
	
    cnx.Compiler.autocomplete.call( [ program , idx ] , function( comps:CompletionResult ) displayCompletions( cm , comps ) );
	}

//   function showHint( cm : CodeMirror ){
//     var src = cm.getValue();
//     var cursor = cm.getCursor();
//     var from = SourceTools.indexToPos( src , SourceTools.getAutocompleteIndex( src, cursor ) );
//     var to = cm.getCursor();

//     var token = src.substring( SourceTools.posToIndex( src, from ) , SourceTools.posToIndex( src, to ) );

//     var list = [];

//     for( c in completions ){
//       if( c.toLowerCase().startsWith( token.toLowerCase() ) ){
//         list.push( c );
//       }
//     }

//     return {
//         list : list,
//         from : from,
//         to : to
//     };
//   }

	public function displayCompletions(cm : CodeMirror , comps : CompletionResult ) {
	
    completions = null;
    if (comps.list != null) {
  		completions = comps.list;
        
        Completion.completions = [];
        
        for (completion in completions)
        {
        	Completion.completions.push({n: completion});
        }
        
      	cm.execCommand("autocomplete");
    }
    if (comps.type != null) {
      trace(comps.type);
       var pos = cm.getCursor();
       var end = {line:pos.line, ch:pos.ch+comps.type.length};
       cm.replaceRange(comps.type, pos, pos);
       cm.setSelection(pos, end);
    } 
    if (comps.errors != null) {
      messages.html( "<div class='alert alert-error'><h4 class='alert-heading'>Completion error</h4><div class='message'></div></div>" );
      for( m in comps.errors ){
        messages.find(".message").append( new JQuery("<div>").text(m) );  
      }
      messages.fadeIn();
      markErrors(comps.errors);
    }
	}

  public function onKey( e : JqEvent ){
     /*if( e.keyCode == 27 ){ // Escape
        new JQuery("body").removeClass("fullscreen-source fullscreen-runner");
     }*/
     if( e.keyCode == 122 ){
        var b = new JQuery("body");
        if( b.hasClass("fullscreen-runner") ){
          b.removeClass("fullscreen-runner");
        }
     }
     if( ( e.ctrlKey && e.keyCode == 13 ) || e.keyCode == 119 ){ // Ctrl+Enter and F8
        e.preventDefault();
        compile(e);
     }
   
  }

	public function onChange( cm :CodeMirror, e : js.codemirror.CodeMirror.ChangeEvent ){
    var txt :String = e.text[0];
        
    if( txt.trim().endsWith( "." ) || txt.trim().endsWith( "()" ) ){
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
		program.main.name = mainName.val();
    program.dce = new JQuery( 'input[name=\'dce\']:checked' ).val();

		var libs = new Array();
    var sel = Type.enumConstructor(program.target);
	
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
    Browser.window.location.hash = "#" + output.uid;
		
		jsSource.setValue( output.source );
    embedSource.setValue( output.embed );
    embedPreview.html( output.embed );

    if( output.embed != "" && output.embed != null ){
      embedTab.show();
    }else{
      embedTab.hide();
    }

    var jsSourceElem = new JQuery(jsSource.getWrapperElement());
		var msg : Array<String> = [];
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
      msg = SourceTools.splitLines(output.stderr);
      msgType = "error";
      stage.hide();
      jsTab.hide();
      jsSourceElem.hide();
      markErrors(output.errors);
		}

    messages.html( "<div class='alert alert-"+msgType+"'><h4 class='alert-heading'>" + output.message + "</h4><div class='message'></div></div>" );
    for( m in msg ){
      messages.find(".message").append( new JQuery("<div>").text(m) );  
    }
    

    if( output.success && output.stderr != null ){
      messages.append( new JQuery("<pre>").text(output.stderr) );
      
    }

    messages.fadeIn();
		compileBtn.buttonReset();

		run();

	}

  public function clearErrors(){
      HaxeLint.data = [];
      HaxeLint.updateLinting(haxeSource);
//     for( m in markers ){
//       m.clear();
//     }
//     markers = [];
//     for( l in lineHandles ){
//       haxeSource.clearMarker( l );
//     }
  }

  public function markErrors(errors:Array<String>){
    HaxeLint.data = [];  
      
    var errLine = ~/([^:]*):([0-9]+): characters ([0-9]+)-([0-9]+) :(.*)/g;
    
    for( e in errors ){
      if( errLine.match( e ) ){
        var err = {
          file : errLine.matched(1),
          line : Std.parseInt(errLine.matched(2)) - 1,
          from : Std.parseInt(errLine.matched(3)),
          to : Std.parseInt(errLine.matched(4)),
          msg : errLine.matched(5)
        };
        
        if( StringTools.trim( err.file ) == "Test.hx" ){
            HaxeLint.data.push({from:{line:err.line, ch:err.from}, to:{line:err.line, ch:err.to}, message:err.msg, severity:"error"});
          //trace(err.line);
//           var l = haxeSource.setMarker( err.line , "<i class='icon-warning-sign icon-white'></i>" , "error");
//           lineHandles.push( l );

//           var m = haxeSource.markText( { line : err.line , ch : err.from } , { line : err.line , ch : err.to } , "error");
//           markers.push( m );
        }
        
      }
    }

	HaxeLint.updateLinting(haxeSource);
  }

}
