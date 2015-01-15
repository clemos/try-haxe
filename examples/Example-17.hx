@:generic
class MyValue<T> {
	public var value:T;
		public function new(value:T) {
		this.value = value;
	}
}

class Test {
	static public function main() {
		var a = new MyValue<String>("HI!");
		var b = new MyValue<Int>(5);
		
		// Compile-time type warnings
		$type(a.value);
		$type(b.value);
	}
}
