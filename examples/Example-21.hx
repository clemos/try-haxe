class Test {
	// this example uses array matching : 
	// http://haxe.org/manual/lf-pattern-matching-structure.html

	static function main() {
		var ranking = {
			name: "Haxe",
			rating: "awesome"
		}

		// a switch can directly return something
		var description = switch (ranking)
		{
			case { rating: "poor", name: "Haxe" }: 'Haxe is poor?'; 
			case { rating: "awesome", name: n }: '$n is awesome!';
			case _: "no awesome language found";
		}
		
		trace('description: ${description}');
	}
}	
