package ;

import api.Program;

using Lambda;

typedef LibConf = {
	name : String,
	?args : Array<String>
}

typedef AvailableLibs = {
	js : Array<LibConf>,
	swf : Array<LibConf>
}

class Libs
{

	public static var available : AvailableLibs = {
		js : [
			{name:"jeash", args : ["--remap","flash:jeash"]},
			{name:"selecthx"},
			{name:"modernizr"},
			{name:"browserhx"}
		],
		swf : [
			{name:"actuate" , args : []},
			{name:"hxSet"}
		]
	};

	public static var defaultChecked : Array<String> = []; // array of lib names

	static public function getAvailableLibs(target:Target):Array<Library> 
	{
		var res:Array<Library> = new Array();

		var availableOnTarget = switch (target) {
			case JS(_): available.js;
			case SWF(_, _): available.swf;	
		}

		for( l in availableOnTarget ){
			res.push({
				name:l.name, 
				checked:defaultChecked.has( l.name ) 
			}); // libs can be checked by default
		}

		return res;
	} 

}