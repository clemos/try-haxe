@:generic
class MyArray<T> {
	public function new() { }
}

class Test {
	static public function main() {
		var a = new MyArray<String>();
		var b = new MyArray<Int>();
	}
}