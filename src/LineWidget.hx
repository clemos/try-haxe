package;
import js.codemirror.CodeMirror;
import js.codemirror.CodeMirror.Pos;
import js.Browser;
import js.html.DivElement;
import js.html.SpanElement;

/**
 * ...
 * @author AS3Boyan
 */
class LineWidget
{
	var element:DivElement;
	var parametersSpanElements:Array<SpanElement>;
	var widget:Dynamic;
	
	public function new(cm:CodeMirror, type:String, name:String, parameters:Array<String>, retType:String, description:String, currentParameter:Int, pos:Pos) 
	{		
		element = Browser.document.createDivElement();
		//var icon:SpanElement = Browser.document.createSpanElement();
		//msg.appendChild(icon);
		//icon.className = "lint-error-icon";
		element.className = "lint-error";
		
		var spanText:SpanElement = Browser.document.createSpanElement();
		spanText.textContent = type + " " + name + "(";
		element.appendChild(spanText);
		
		var parametersSpan:SpanElement = Browser.document.createSpanElement();
		spanText.appendChild(parametersSpan);
		
		parametersSpanElements = [];
		
		for (i in 0...parameters.length)
		{
			var spanText2 = Browser.document.createSpanElement();
			spanText2.textContent = parameters[i];
			
			if (i == currentParameter) 
			{
				spanText2.className = "selectedParameter";
			}
			
			parametersSpan.appendChild(spanText2);
			parametersSpanElements.push(spanText2);
			
			if (i != parameters.length - 1) 
			{
				var spanCommaText:SpanElement = Browser.document.createSpanElement();
				spanCommaText.textContent = ", ";
				parametersSpan.appendChild(spanCommaText);
			}
		}
		
		updateParameters(currentParameter);
		
		var spanText3:SpanElement = Browser.document.createSpanElement();
		spanText3.textContent = "):" + retType;
		element.appendChild(spanText3);
		
		if (description != null) 
		{
			element.appendChild(Browser.document.createBRElement());
			var spanDescription:SpanElement = Browser.document.createSpanElement();
			spanDescription.innerHTML = description;
			element.appendChild(spanDescription);
		}
		
		widget = cm.addLineWidget(pos.line, element, { coverGutter: false, noHScroll: true } );
	}
	
	public function updateParameters(currentParameter:Int) 
	{
		for (i in 0...parametersSpanElements.length) 
		{
			if (i == currentParameter) 
			{
				parametersSpanElements[i].className = "selectedParameter";
			}
			else 
			{
				parametersSpanElements[i].className = "";
			}
		}
	}
	
	public function getWidget():Dynamic
	{
		return widget;
	}
	
	public function getElement():DivElement 
	{
		return element;
	}
	
}
