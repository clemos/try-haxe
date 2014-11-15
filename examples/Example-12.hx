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
    // { author : ["Nicolas"], debug : null }
    trace(Std.string(Meta.getType(MyClass)));
    // [1,8]
    trace(Meta.getFields(MyClass).value.range);
    // { broken: null }
    trace(Std.string(Meta.getStatics(MyClass).method));
  }
}