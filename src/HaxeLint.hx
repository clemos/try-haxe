package ;

typedef Info = {
	var from:CodeMirror.Pos;
	var to:CodeMirror.Pos;
	var message:String;
	var severity:String;
}

/**
 * ...
 * @author AS3Boyan
 */

//Ported from HIDE, adjusted for try-haxe
class HaxeLint
{
	public static var data:Array<Info> = [];

	public static function load():Void
	{
		CodeMirror.registerHelper("lint", "haxe", function (text:String) 
		{
			var found = [];
			found = data;
			return found;
		}
		);
	}
    
    public static function updateLinting(cm:CodeMirror):Void
	{
		cm.setOption("lint", false);
		cm.setOption("lint", true);
	}
	
}