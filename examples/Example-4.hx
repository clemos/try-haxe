class Test {
    static function main() {
     	var people = [
            "Elizabeth" => "Programming",
          	"Joel" => "Design"
        ];
        
        for (name in people.keys()) {
          	var job = people[name];
          	trace('$name does $job for a living!');
        }
    }
}