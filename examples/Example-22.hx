class Test {
    static function main() {
        var r = new haxe.unit.TestRunner();
        r.add(new MyTests());
        r.run();
    }
}

class MyTests extends haxe.unit.TestCase {
    var myVal:String;
    var myInt:Int;

    override public function setup() {
        myVal = "foo";
        myInt = 1+1;
    }
    
    /* Every test function name has to start with 'test' */
    
    public function testValue() {
        assertEquals("foo", myVal);
    }
    
    public function testMath1() {
        assertTrue(myInt == 2);
    }
    
    public function testMath2() {
        assertFalse(myInt == 3);
    }
}
