package;
import api.Completion.CompletionType;
import api.Completion.CompletionResult;
import js.codemirror.CodeMirror;
import js.codemirror.CodeMirror.Pos;
import api.Completion.CompletionItem;
import js.Browser;
import js.html.DivElement;
import js.html.SpanElement;

/**
 * ...
 * @author AS3
 */
class FunctionParametersHelper
{
	public var widgets:Array<LineWidget> = [];
	var lastPos:Pos;
	
	public function new()
	{
			
	}
	
	public function addWidget(cm:CodeMirror, type:String, name:String, parameters:Array<String>, retType:String, description:String, currentParameter:Int, pos:Pos):Void
	{		
		var lineWidget:LineWidget = new LineWidget(cm, type, name, parameters, retType, description, currentParameter, pos);
		widgets.push(lineWidget);
	}
	
	public function alreadyShown():Bool
	{
		return widgets.length > 0;
	}
	
	public function updateScroll(cm:CodeMirror):Void
	{
		var info = cm.getScrollInfo();
		var after = cm.charCoords( { line: cm.getCursor().line + 1, ch: 0 }, "local").top;
		
		if (info.top + info.clientHeight < after)
		{
			cm.scrollTo(null, after - info.clientHeight + 3);
		}
	}
	
	public function clear(cm:CodeMirror):Void
	{
		for (widget in widgets) 
		{
			cm.removeLineWidget(widget.getWidget());
		}
		
		widgets = [];
	}
	
	public function update(completionInstance:Completion, editorInstance:Editor, cm:CodeMirror):Void
	{
		var doc = cm.getDoc();
		
		if (doc != null)
		{
			var modeName:String = doc.getMode().name;
			
			if (modeName == "haxe" && !cm.state.completionActive)
			{	
				var cursor = cm.getCursor();
				var data = cm.getLine(cursor.line);			

				if (cursor != null && data.charAt(cursor.ch - 1) != ".")
				{
					scanForBracket(completionInstance, editorInstance, cm, cursor);
				}
			}
		}
	}
	
	function scanForBracket(completionInstance:Completion, editorInstance:Editor, cm:CodeMirror, cursor:Pos):Void
	{
		//{bracketRegex: untyped __js__("/[([\\]]/")}
        //{bracketRegex: untyped __js__("/[({}]/")}
        var bracketsData = cm.scanForBracket(cursor, -1, null, {bracketRegex: untyped __js__("/[([\\]]/")});
        
        var pos:Pos = null;
        
		if (bracketsData != null && bracketsData.ch == "(") 
		{
            pos = {line:bracketsData.pos.line, ch:bracketsData.pos.ch};
            
            var matchedBracket:Pos = cm.findMatchingBracket(pos, false, null).to;
            
            if (matchedBracket == null || (cursor.line <= matchedBracket.line && cursor.ch <= matchedBracket.ch))
            {
                var range:String = cm.getRange(bracketsData.pos, cursor);
			
                var currentParameter:Int = range.split(",").length - 1;
                
                if (lastPos == null || lastPos.ch != pos.ch || lastPos.line != pos.line)
                {
                    getFunctionParams(completionInstance, editorInstance, cm, pos, currentParameter);  
                }
                else if (alreadyShown())
                {
                    for (widget in widgets)
					{
						widget.updateParameters(currentParameter);	 
					}
                }
                
                lastPos = pos;
			}
            else
            {
                lastPos = null;
                clear(cm);
            }
		}
		else
		{
            lastPos = null;
			clear(cm);
		}
	}
	
	function getFunctionParams(completionInstance:Completion, editorInstance:Editor, cm:CodeMirror, pos:Pos, currentParameter:Int):Void
	{
		var posBeforeBracket:Pos = {line:pos.line, ch:pos.ch - 1};
		
		var word = completionInstance.getCurrentWord(cm, {}, posBeforeBracket).word;
        
		editorInstance.getCompletion(cm, function (cm:CodeMirror, comps:CompletionResult)
		{
			var found:Bool = false;
			
			clear(cm);
			
			for (completion in completionInstance.completions) 
			{							
				if (word == completion.n) 
				{
					var functionData = parseFunctionParams(completion.n, completion.t, completion.d);
					
					if (functionData.parameters != null)
					{
						var description = parseDescription(completion.d);
						addWidget(cm, "function", completion.n, functionData.parameters, functionData.retType, description, currentParameter, cm.getCursor());
						found = true;
// 						break;
					}
				}
			}
				
			updateScroll(cm);
			
// 			if (!found) 
// 			{
// 				FunctionParametersHelper.clear();
// 			}  
		}
		, posBeforeBracket, CompletionType.DEFAULT);
	}
	
	function parseDescription(description:String)
	{						
		if (description != null) 
		{
			if (description.indexOf(".") != -1) 
			{
				description = description.split(".")[0];
			}
		}
		
		return description;
	}
	
	public function parseFunctionParams(name:String, type:String, description:String)
	{
		var parameters:Array<String> = null;
		
		var retType:String = null;
		
		if (type != null && type.indexOf("->") != -1) 
		{
			var openBracketsCount:Int = 0;
			var positions:Array<{start:Int, end:Int}> = [];
			var i:Int = 0;
			var lastPos:Int = 0;
			
			while (i < type.length) 
			{				
				switch (type.charAt(i)) 
				{
					case "-":
						if (openBracketsCount == 0 && type.charAt(i + 1) == ">") 
						{
							positions.push({start: lastPos, end: i-1});
							i++;
							i++;
							lastPos = i;
						}
					case "(":
						openBracketsCount++;
					case ")":
						openBracketsCount--;
					default:
						
				}
				
				i++;
			}
			
			positions.push( { start: lastPos, end: type.length } );
			
			parameters = [];
			
			for (j in 0...positions.length) 
			{
				var param:String = StringTools.trim(type.substring(positions[j].start, positions[j].end));
				
				if (j < positions.length - 1) 
				{
					parameters.push(param);
				}
				else 
				{
					retType = param;
				}
			}
			
			if (parameters.length == 1 && parameters[0] == "Void") 
			{
				parameters = [];
			}
		}
		
		return {parameters: parameters, retType: retType};
	}
}
