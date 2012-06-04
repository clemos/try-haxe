package js.codemirror;

import js.Dom;

typedef Completions = {
	list : Array<String>,
	from : Pos,
	to : Pos,
}

typedef Pos = {
	line : Int,
	ch : Int
}

@:native('CodeMirror') extern class CodeMirror {

	public static var commands (default,null) : Dynamic<CodeMirror->Void>;
	public static function simpleHint( cm : CodeMirror , getCompletions : CodeMirror -> Completions ) : Void;

	public static function fromTextArea( textarea : Textarea , ?config : Dynamic ) : CodeMirror;

	public function setValue( v : String ) : Void;
	public function getValue() : String;
	public function refresh() : Void;

	public function getCursor( ?start : Bool ) : Pos;

}