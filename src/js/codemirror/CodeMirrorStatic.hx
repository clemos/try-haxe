package js.codemirror;

/**
 * ...
 * @author AS3Boyan
 */

//Ported from HIDE, adjusted for try-haxe

typedef ShowHintOptions = {
	@:optional var closeCharacters:Dynamic;
	@:optional var completeSingle:Bool;
	@:optional var alignWithWord:Bool;
}
 
@:native("CodeMirror")
extern class CodeMirrorStatic
{
    public static var Pass:Dynamic;
	@:overload(function (object:Dynamic, event:String, callback_function:Dynamic):Void {})
	static function on(event:String, callback_function:Dynamic):Void;
	static function showHint(cm:CodeMirror, getHints:Dynamic, ?options:ShowHintOptions):Void;
	static function attachContextInfo(cm:CodeMirror, data:Dynamic):Void;
    static function innerMode(mode:Dynamic, state:Dynamic):Dynamic;
}