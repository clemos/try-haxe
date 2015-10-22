class Point {
	public var x:Float;
	public var y:Float;

	public inline function new(x:Float, y:Float) {
		this.x = x;
		this.y = y;
	}
}

class Test {
	static public function main() {
		// look at the "JS Source"-tab to reveal the effect 
		var pt = new Point(1.2, 9.3);
		trace(pt.x);
	}
}
