import api.Program;

typedef SWFInfo = {
	src:String,
}

typedef LibConf = {
	name : String,
	?args : Array<String>,
	?head:Array<String>,
	?body:Array<String>,
	?swf:SWFInfo,
	?help:String
}


class Libs
{

	static var available : Map<String, Array<LibConf>> = [
		"JS" => [
			//{name:"nme", args : ["--remap","flash:browser"], head : ["<link rel='stylesheet' href='../swf.css' type='text/css'/>"], body:["<div id='haxe:jeash'></div>"]},
			{name:"actuate" , help:"https://github.com/openfl/actuate",args : []},
			//{name:"selecthx"},
			//{name:"modernizr"},
			//{name:"browserhx"},
			{name:"format", help:"https://github.com/HaxeFoundation/format"},
			{name:"tink_core", help:"https://github.com/fponticelli/thx.core"},
			{name:"thx.core", help:"https://github.com/haxetink/tink_core"},
			{name:"hxColorToolkit", help:"https://github.com/andyli/hxColorToolkit"},
			{name:"threejs", head: ["<script src='../../../lib/js/stats-min.js'></script>", "<script src='../../../lib/js/three-min.js'></script>"]},
			{name:"pixijs"},
		],
		"SWF" => new Array<LibConf>().concat([
			{name:"actuate" , help:"https://github.com/openfl/actuate",args : []},
			{name:"format", help:"https://github.com/HaxeFoundation/format"},
			{name:"tink_core", help:"https://github.com/fponticelli/thx.core"},
			{name:"thx.core", help:"https://github.com/haxetink/tink_core"},
			{name:"hxColorToolkit", help:"https://github.com/andyli/hxColorToolkit"},
			{name:"away3d", swf:{src:"away3d4.swf"}, help:"http://away3d.com/livedocs/away3d/4.0/"},
			//{name:"starling" },
		])
	];
	
	static var defaultChecked : Map < String, Array<String> > = ["JS" => [], "SWF" => []]; // array of lib names
	
	
	static public function getLibsConfig(?target:Target, ?targetName:String):Array<LibConf>
	{
		var name = targetName != null ? targetName : Type.enumConstructor(target);
		return if (available.exists(name)) return available.get(name) else [];
	}

	static public function getDefaultLibs(?target:Target, ?targetName:String):Array<String>
	{
		var name = targetName != null ? targetName : Type.enumConstructor(target);
		return if (defaultChecked.exists(name)) return defaultChecked.get(name) else [];
	}
}