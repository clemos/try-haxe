package api;

typedef Program = {
	uid : String,
	main : Module,
	target : Target,
	libs:Array<String>,
//	?modules : Hash<Module>,
}

typedef Library =
{
	name:String,
	?checked:Bool,
	?args:Array<String> // aditional args like --remap flash:nme ...
}

typedef Module = {
	name : String,
	source : String
}

enum Target {
	JS( name : String );
	SWF( name : String , ?version : Int );
}

typedef Output = {
	uid : String,
	stderr : String,
	stdout : String,
	args : Array<String>,
	errors : Array<String>,
	success : Bool,
	message : String,
	href : String,
	source : String
}