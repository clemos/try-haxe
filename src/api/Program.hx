package api;

typedef Program = {
	uid : String,
	main : Module,
	target : Target,
	libs:Array<String>,
	dce : String
//	?modules : Hash<Module>,
}

typedef Module = {
	name : String,
	source : String
}

enum Target {
	JS( name : String );
	SWF( name : String , ?version : Float );
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
	source : String,
	embed : String
}
