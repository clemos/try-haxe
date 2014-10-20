class Test {
    static function main() {
        var point2d = new Point2d(100, 200);
		trace(point2d.toString());
		
		var point3d = new Point3d(100, 200, 150);
		trace(point3d.toString());
    }
}

class Point2d {
	public var x:Int;
	public var y:Int;

	public function new(x, y) {
		this.x = x;
		this.y = y;
	}

	public function toString() {
		return 'Point2d: x=$x, y=$y';
	}
}

class Point3d extends Point2d {
	public var z:Int;

	public function new(x, y, z) {
		super(x, y);
		this.z = z;
	}

	override public function toString() {
		return 'Point3d: x=$x, y=$y, z=$z';
	}
}