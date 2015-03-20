
class MyClass {
	
	@:allow(Test)
    static private var foo: Int = 1;
	
    static private var bar: Int = 2;
	
    static private var boo: Int = 3;
}

class Test {
	@:access(MyClass.bar)
    static public function main() {
        // possible because of given access at MyClass
		trace(MyClass.foo);
		
		// possible because of requested access at Test constructor
        trace(MyClass.bar);
		
		// impossible 
        // trace(MyClass.boo);
    }
}