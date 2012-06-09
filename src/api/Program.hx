package api;

typedef Program = {
	uid : String,
	main : Module,
	target : Target,
	libs:Array<String>,
//	?modules : Hash<Module>,
}

typedef Module = {
	name : String,
	source : haxe.io.Bytes
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
	source : haxe.io.Bytes
}