using StringTools;

class Test {
	static public function main() {
		// uses static extension StringTools from the Haxe Standard Library
		var v = "adc".replace("d", "b");
		trace(v);
	}
}