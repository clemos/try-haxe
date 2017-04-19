using Lambda;

class SourceTools {

	public static function splitLines(str:String):Array<String> {
		return ~/\r\n|\n|\r/g.split(str);
	}

	public static function indexToPos( src :String , idx : Int ) : { line : Int , ch : Int } {
		var pos = {
			line : 0,
			ch : 0
		};
		var lines = splitLines(src);
		for( l in lines ){
			if( idx >= l.length+1 ){
				idx -= l.length+1;
				pos.line++;
			}else{
				pos.ch += idx;
				break;
			}
		}

		return pos;

	}
	public static function posToIndex( src :String, pos : { line : Int, ch : Int } ){
		var char = 0;
		var lines = splitLines(src);

		for( i in 0...pos.line ){
			char += lines[i].length + 1;
		}
		char += pos.ch;
		return char;
	}

	public static function getAutocompleteIndex( src : String , pos : { line : Int , ch : Int } ) : Null<Int>{
		var charPos = posToIndex( src , pos );
		var charCode = src.charCodeAt(charPos);
		var iniChar = charPos;

		while( "(".code != charCode && ",".code != charCode && ".".code != charCode ){
			charPos--;
			charCode = src.charCodeAt(charPos);
			if( charPos < 0 ) return null;
		}

		charPos++;

		var skipped = src.substring( iniChar , charPos );

		if( ~/[^a-zA-Z0-9_\s]/.match( skipped ) ){
			return null;
		}

		return charPos;
	}
}
