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

typedef CompletionItem = 
{
	@:optional
	var d:String;
	@:optional
	var t:String;
	@:optional
	var k:String;
	var n:String;
}

typedef CompletionResult = {
	@:optional var type:String;
	@:optional var list:Array<CompletionItem>;
	@:optional var errors:Array<String>;
}