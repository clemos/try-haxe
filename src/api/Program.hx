package api;

typedef Program = {
	uid : String,
	main : Module,
	target : Target,
	libs:Array<Library>,
//	?modules : Hash<Module>,
//	?libs : Array<String>
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
	success : Bool,
	message : String,
	href : String,
	source : String
}