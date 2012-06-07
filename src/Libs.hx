package ;

import api.Program;

using Lambda;

class Libs
{

	public static var available = {
		js : ["jeash","selecthx","modernizr","divtastic","browserhx","zpartanlite"],
		swf : ["actuate","hxSet"]
	};

	public static var defaultChecked = [];

	static public function getAvailableLibs(target:Target):Array<Library> 
	{
		var res:Array<Library> = new Array();

		var availableOnTarget = switch (target) {
			case JS(_): available.js;
			case SWF(_, _): available.swf;	
		}

		for( name in availableOnTarget ){
			res.push({
				name:name, 
				checked:defaultChecked.has( name ) 
			}); // libs can be checked by default
		}

		return res;
	} 

}