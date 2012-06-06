package ;

import api.Program;

class Libs
{

	static public function getLibs(target:Target):Array<Library> 
	{
		var res:Array<Library> = new Array();

		res.push({name:"hxSet"});

		switch (target) {
			case JS(_):
				res.push({name:"browserhx", checked:false}); // libs can be checked by default
			case SWF(_, _):
				res.push({name:"actuate"});
			
		}

		return res;
	} 

}