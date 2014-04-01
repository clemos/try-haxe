package js.codemirror;

//CodeMirror.hx from "try-haxe"
//https://github.com/clemos/try-haxe/blob/master/src/js/codemirror/CodeMirror.hx
//With few additional functions
//==========

//Ported from HIDE

import js.html.DivElement;
import js.html.Element;

typedef Completions = {
list : Array<String>,
from : Pos,
to : Pos,
}

typedef Pos = {
line : Int,
ch : Int
}

typedef MarkedText = {
clear : Void->Void,
find : Void->Pos
}

typedef LineHandle = {};

typedef ChangeEvent = {
from : Pos,
to : Pos,
text : Array<String>,
?next : ChangeEvent
}

typedef LineWidgetOptions = {
	coverGutter: Bool,
	noHScroll: Bool
}

typedef DocHistory = {
	var generation:Int;
}

@:native('CodeMirror.Doc') extern class Doc 
{
	public function new(body: Dynamic, mode: String, ?firstLineNumber:Int);
	public function getValue():String;
	function somethingSelected():Bool;
	function setValue(value:String):Void;
	function getSelection(?lineSep:String):String;
	function markClean():Void;
	function clearHistory():Void;
	function historySize():Int;
	var history:DocHistory;
}

@:native('CodeMirror') extern class CodeMirror {

static var keyMap:Dynamic;
public var gutters:Array<String>;
public var state:Dynamic;

public static var prototype:Dynamic;

public static var commands (default,null) : Dynamic<CodeMirror->Void>;
//public static function simpleHint( cm : CodeMirror , getCompletions : CodeMirror -> Completions ) : Void;

public static function fromTextArea( textarea : Dynamic , ?config : Dynamic ) : CodeMirror;

public static function registerHelper(type:String, mode:String, onCompletion:Dynamic):Void;

@:overload(function (object:Dynamic, event:String, callback_function:Dynamic):Void {})
public function on(event:String, callback_function:Dynamic):Void;

public function setValue( v : String ) : Void;
public function getValue() : String;
public function refresh() : Void;

public function getCursor( ?start : Bool ) : Pos;

public function getLine(line:Int):String;
public function getLineNumber(pos:Pos):Int;
	
public function firstLine():Dynamic;
public function lastLine():Dynamic;

public function setOption(option:String, value:Dynamic):Void;
public function swapDoc(doc:Dynamic):Void;
public function getDoc():Dynamic;

@:overload(function (lineHandle: LineHandle, gutterID: String, value: Element):LineHandle {})
public function setGutterMarker(line: Int, gutterID: String, value: Element):LineHandle;
public function indexFromPos(pos:Pos):Int;
public function posFromIndex(index:Int):Pos;
public function getMode():Dynamic;

public function addLineWidget(line:Int, msg:DivElement, options:LineWidgetOptions):Dynamic;
public function removeLineWidget(widget:Dynamic):Void;

public function getScrollInfo():Dynamic;
public function scrollTo(param1:Dynamic, y:Int):Void;
public function charCoords(param1:Dynamic, param2:String):Dynamic;
function cursorCoords(start:Bool):{left:Int, right:Int, top:Int, bottom:Int};
public function getScrollerElement():Dynamic;
public function scrollIntoView(from:Pos, to:Pos):Dynamic;
public static function defineExtension(name:String, func:Dynamic):Void;
public function centerOnLine(line:Int):Void;
public function scanForBracket(pos:CodeMirror.Pos, dir:Int, ?style:Dynamic, ?config:Dynamic): { ch:String, pos:CodeMirror.Pos };
public function execCommand(command:String):Void;
public function replaceRange(replacement: String, from: Pos, to: Pos, ?origin: String):Void;
public function setSelection(anchor: Pos, ?head: Pos, ?options: Dynamic):Void;
    
public function markText(from : Pos, to : Pos, className : String ) : MarkedText;

public function setMarker( line : Int , ?text : String , ?className : String ) : LineHandle;
@:overload( function( line : LineHandle ) : Void {})
public function clearMarker(line:Int) : Void;

public function getWrapperElement() : DivElement;

public function somethingSelected() : Bool;
public function focus() : Void;

}