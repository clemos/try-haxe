package ;

/**
 * ...
 * @author AS3Boyan
 */

//Ported from HIDE
class CodeMirrorPos
{
	static var pos:Dynamic;
	
	inline public static function from(line:Int, ch:Int):Dynamic
	{
		return pos(line, ch);
	}
	
	static function __init__() : Void
	{
		pos = untyped __js__("CodeMirror.Pos");
	}
}