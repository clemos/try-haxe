package api;

typedef Completion = {
	trigger : String,
	contents : String
}

enum CompletionType {
	DEFAULT;
	TOP_LEVEL;
}

typedef CompletionResult = {
	@:optional var type:String;
	@:optional var list:Array<String>;
	@:optional var errors:Array<String>;
}