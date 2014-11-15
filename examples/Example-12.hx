import haxe.rtti.Meta;

@author("Nicolas")
@debug
class MyClass {
  @range(1, 8)
  var value:Int;

  @broken
  @:noCompletion
  static function method() { }
    
  public function new() { value = 0; }
}

class Test {
  static public function main() {
    var value = new MyClass();
    var meta = Meta.getType(MyClass);
    // { author : ["Nicolas"], debug : null }
    trace(Std.string(meta));
    // [1,8]
    trace(Meta.getFields(MyClass).value.range);
    // { broken: null }
    trace(Std.string(Meta.getStatics(MyClass).method));
  }
}