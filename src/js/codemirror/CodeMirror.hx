package js.codemirror;

import js.Dom;

@:native('CodeMirror') extern class CodeMirror {

	public static function fromTextArea( textarea : Textarea , ?config : Dynamic ) : CodeMirror;

	public function setValue( v : String ) : Void;
	public function getValue() : String;
	public function refresh() : Void;

}