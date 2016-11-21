package;

/**
 * ...
 * @author AS3
 */
class FunctionParametersHelper
{
	static var instance:FunctionParametersHelper = null;
	
	public function new()
	{
			
	}
	
	public static function get()
	{
		if (instance == null)
		{
			instance = new FunctionParametersHelper();
		}
		
		return instance;
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
