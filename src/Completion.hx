package;
import haxe.xml.Fast;
import js.Browser;
import js.html.DivElement;
import js.codemirror.*;
/**
 * ...
 * @author AS3Boyan
 */

//Ported from HIDE, adjusted for try-haxe
 
typedef CompletionItem = 
{
	@:optional
	var d:String;
	@:optional
	var t:String;
	var n:String;
}
    
typedef CompletionData =
{
	var text:String;
	@:optional var displayText:String;
	@:optional var hint:CodeMirror->Dynamic->CompletionData->Void;
}
 
class Completion
{
	static var list:Array<CompletionData>;
	static var editor:CodeMirror;
	static var word:EReg;
	static var range:Int;
	static var cur:CodeMirror.Pos;
	static private var end:Int;
	static private var start:Int;
	static var WORD:EReg = ~/[A-Z]+$/i;
	static var RANGE = 500;
	public static var curWord:String;
	public static var completions:Array<CompletionItem> = [];
	static var backupDocValue:String;
	
	public static function registerHelper() 
	{		
		CodeMirror.registerHelper("hint", "haxe", function(cm:CodeMirror, options) {
			word = null;
			
			range = null;
			
			if (options != null && options.range != null)
			{
				range = options.range;
			}
			else if (RANGE != null)
			{
				range = RANGE;
			}
			
			getCurrentWord(cm, options, cm.getCursor());

			list = new Array();
			
            for (completion in completions) 
            {
                list.push( { text: completion.n } );
            }
			
			list = Filter.filter(list, curWord);
			
        var data:Dynamic = { list: list, from: {line:cur.line, ch:start}, to: {line:cur.line, ch:end} };
			return data;
		});
	}

	public static function getCurrentWord(cm:CodeMirror, ?options:Dynamic, ?pos:CodeMirror.Pos):String
	{
		if (options != null && options.word != null)
		{
			word = options.word;
		}
		else if (WORD != null)
		{
			word = WORD;
		}
		
		if (pos != null) 
		{
			cur = pos;
		}
		
		var curLine:String = cm.getLine(cur.line);
		start = cur.ch;
		
		end = start;
		
		while (end < curLine.length && word.match(curLine.charAt(end))) ++end;
		while (start > 0 && word.match(curLine.charAt(start - 1))) --start;
		
		curWord = null;
		
		if (start != end) 
		{
			curWord = curLine.substring(start, end);
		}
		
		return curWord;
	}
}