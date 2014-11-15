enum Schema {
    TInt;
    TString;
    TArray(elem:Schema);
}

class Test {
    static function main() {
        validate([1,2,3], TArray(TInt));
    }

    static function validate(value:Dynamic, schema:Schema) {
        switch (schema) {
            case TInt:
                if (!Std.is(value, Int)) throw "not an int";
            case TString:
                if (!Std.is(value, String)) throw "not a string";
            case TArray(elemSchema):
                if (!Std.is(value, Array)) throw "not an array";
                for (elem in (value : Array<Dynamic>))
                    validate(elem, elemSchema);
        }
    }
}