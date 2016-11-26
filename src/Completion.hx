package;
import haxe.xml.Fast;
import js.Browser;
import js.html.DivElement;
import js.html.SpanElement;
import js.codemirror.*;
import api.Completion.CompletionItem;
/**
 * ...
 * @author AS3Boyan
 */

//Ported from HIDE, adjusted for try-haxe
    
typedef CompletionData =
{
	@:optional var text:String;
	@:optional var displayText:String;
	@:optional var hint:CodeMirror->Dynamic->CompletionData->Void;
	@:optional var info:CompletionData->Dynamic;
	@:optional var className:String;
}
 
class Completion
{
	var list:Array<CompletionData>;
	var editor:CodeMirror;
	var word:EReg;
	var range:Int;
	var cur:CodeMirror.Pos;
	private var end:Int;
	private var start:Int;
	var WORD:EReg = ~/[A-Z]+$/i;
	var RANGE = 500;
	public var curWord:String;
	public var completions:Array<CompletionItem> = [];
	var backupDocValue:String;
	var functionParametersHelper:FunctionParametersHelper;
	
	public function new()
	{
		
	}
	
	public function registerHelper(p_functionParametersHelper:FunctionParametersHelper) 
	{
		functionParametersHelper = p_functionParametersHelper;
	
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
                var completionItem = generateCompletionItem(completion.n, completion.t, completion.d, completion.k);
				list.push(completionItem);
            }
			
			list = Filter.filter(list, curWord);
			
			var data:Dynamic = { list: list, from: {line:cur.line, ch:start}, to: {line:cur.line, ch:end} };
			
			CodeMirrorStatic.attachContextInfo(cm, data);
			
			return data;
		});
	}

	public function getCurrentWord(cm:CodeMirror, ?options:Dynamic, ?pos:CodeMirror.Pos):{word:String, from:CodeMirror.Pos, to:CodeMirror.Pos}
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
		
		return {word:curWord, from: {line:cur.line, ch: start}, to: {line:cur.line, ch: end}};
	}
	
	function searchImage(name:String, ?type:String, ?description:String, ?k:String)
	{
		var functionData = functionParametersHelper.parseFunctionParams(name, type, description);
		
		var info:String = null;

		var className = "CodeMirror-Tern-completion";

		if (functionData.parameters != null) 
		{
			var data = generateFunctionCompletionItem(name, functionData.parameters);
			className = data.className;
			info = data.info + ":" + functionData.retType;
		}
		else if (type != null)
		{
			info = type;

			switch (info) 
			{
				case "Bool":
					className += " CodeMirror-Tern-completion-bool";
				case "Float", "Int", "UInt":
					className += " CodeMirror-Tern-completion-number";
				case "String":
					className += " CodeMirror-Tern-completion-string";
				default:
					if (info.indexOf("Array") != -1) 
					{
						className += " CodeMirror-Tern-completion-array";
					}
					else if(info.indexOf("Map") != -1 || info.indexOf("StringMap") != -1) 
					{
						className += " CodeMirror-Tern-completion-map";
					}
					else 
					{
						className += " CodeMirror-Tern-completion-object";
					}
			}
		}
		
		if (k != null)
		{
			switch (k)
			{
				case "type":
					className += " CodeMirror-Tern-completion-type";
				case "package":
					className += " CodeMirror-Tern-completion-package";
			}
		}
			
		return {className: className, info: info};
	}

	function generateFunctionCompletionItem(name:String, params:Array<String>)
	{
		var info:String = null;

		var className = "CodeMirror-Tern-completion";
		
		info = name + "(";
		
		if (params != null)
		{
			info += params.join(", ");
		}
			
		info += ")";
		
		className += " CodeMirror-Tern-completion-fn";
		
		return {className: className, info: info};
	}

	function generateCompletionItem(name:String, ?type:String, ?description:String, ?k:String)
	{
		var completionData = searchImage(name, type, description, k);
		return createCompletionItem(name, description, completionData);
	}

	function createCompletionItem(name:String, description:String, completionData:Dynamic)
	{
		var completionItem:CompletionData = { text: name };

		completionItem.className = completionData.className;	

		var infoSpan:SpanElement = Browser.document.createSpanElement();

		if (completionData.info != null)
		{
			var infoTypeSpan:SpanElement = Browser.document.createSpanElement();
			infoTypeSpan.textContent = completionData.info;
			infoSpan.appendChild(infoTypeSpan);

			infoSpan.appendChild(Browser.document.createElement("br"));
		}

		if (description != null)
		{
			var infoDescriptionSpan:SpanElement = Browser.document.createSpanElement();
			infoDescriptionSpan.className = "completionDescription";
			infoDescriptionSpan.innerHTML = description;
			infoSpan.appendChild(infoDescriptionSpan);
		}

		if (completionData.info != null || description != null)
		{
			completionItem.info = function (completionItem) 
			{
				return infoSpan;
			};
		}

		return completionItem;
	}
}