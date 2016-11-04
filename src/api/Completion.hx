package api;

typedef Completion = {
	trigger : String,
	contents : String
}

@:enum
abstract CompletionType(Int) {
	var DEFAULT = 0;
	var TOP_LEVEL = 1;
}

typedef CompletionResult = {
	@:optional var type:String;
	@:optional var list:Array<String>;
	@:optional var errors:Array<String>;
}