class Test {
	// this example uses array matching : 
	// http://haxe.org/manual/lf-pattern-matching-array.html

	static function main() {
		var playerA = {
			name: "Simn",
			move: Move.Paper
		}
		var playerB = {
			name: "Nicolas",
			move: Move.Rock
		}
        
		// a switch can directly return something
		var winner = switch [playerA.move, playerB.move]
		{
			case [Move.Rock, Move.Paper]: playerB;
			case [Move.Rock, Move.Scissors]: playerA;
			case [Move.Paper, Move.Rock]: playerA;
			case [Move.Paper, Move.Scissors]: playerB;
			case [Move.Scissors, Move.Rock]: playerB;
			case [Move.Scissors, Move.Paper]: playerA;
			default: null;
		}
		
		if (winner != null)
		{
			trace('The winner is: ${winner.name}');
		}
		else
		{
			trace('Draw!');
		}
	}
}	

@:enum
abstract Move(Int) 
{
	var Rock = 1;
	var Paper = 2;
	var Scissors = 3;
}
