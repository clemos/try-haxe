class Test {
  static function main() {
    var http = new haxe.Http("https://api.ipify.org?format=json");
    http.onData = function(data) {
      var result:IpAddress = haxe.Json.parse(data);
      trace('Your IP-address: ${result.ip}');
    }
    http.request();
  }
}

typedef IpAddress = { ip:String }
