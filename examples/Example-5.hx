abstract AbstractInt(Int) {
  inline public function new(i:Int) {
    this = i;
  }
}

class Test {
    static function main() {
        var a = new AbstractInt(12);
		trace(a); //12
    }
}