package ;

/**
 * ...
 * @author AS3Boyan
 */

//Ported from HIDE, adjusted for try-haxe

class Filter
{
	public static function filter(completions:Array<Completion.CompletionData>, word:String):Array<Completion.CompletionData>
	{
		var list:Array<Completion.CompletionData> = [];
		
		if (word != null) 
		{
			var filtered_results = [];
			var sorted_results = [];
			
			word = word.toLowerCase();
			
			for (completion in completions) 
			{
				var n = completion.text.toLowerCase();
				var b = true;
			  
				  for (j in 0...word.length)
				  {
					  if (n.indexOf(word.charAt(j)) == -1)
					  {
						  b = false;
						  break;
					  }
				  }

				if (b)
				{
					filtered_results.push(completion);
				}
			}
			
			var results = [];
			var filtered_results2 = [];
			var exactResults = [];
			
			for (i in 0...filtered_results.length) 
			{
				var str = filtered_results[i].text.toLowerCase();
				var index:Int = str.indexOf(word);
				
				if (word == str) 
				{
					exactResults.push(filtered_results[i]);
				}
				else if (index == 0)
				{
					sorted_results.push(filtered_results[i]);
				}
				else if (index != -1) 
				{
					filtered_results2.push(filtered_results[i]);
				}
				else
				{
					results.push(filtered_results[i]);
				}
			}
			
			for (completion in exactResults) 
			{
				list.push(completion);
			}
			
			for (completion in sorted_results) 
			{
				list.push(completion);
			}
			
			for (completion in filtered_results2) 
			{
				list.push(completion);
			}
			
			for (completion in results) 
			{
				list.push(completion);
			}
		}
		else 
		{
			list = completions;
		}
		
		return list;
	}
}