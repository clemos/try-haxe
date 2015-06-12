class Test {
	static function main() {
		draw();
	}

	static function draw() {
	#if js
		var canvas = js.Browser.document.createCanvasElement();
		canvas.width = 400;
		canvas.height = 400;
		js.Browser.document.body.appendChild(canvas);
		
		var ctx = canvas.getContext2d();
		for (part in graphic) {
			ctx.beginPath();
			ctx.fillStyle = '#${part.color}';
			for (i in 0...part.path.length) {
				var point = part.path[i];
				if (i == 0) {
					ctx.moveTo(point.x, point.y);
				} else {
					ctx.lineTo(point.x, point.y);
				}
			}
			ctx.fill();
		}
	#elseif flash
		var ctx = flash.Lib.current.graphics;
		for (part in graphic) {
			ctx.beginFill(Std.parseInt('0x${part.color}'));
			for (i in 0...part.path.length) {
				var point = part.path[i];
				if (i == 0) {
					ctx.moveTo(point.x, point.y);
				} else {
					ctx.lineTo(point.x, point.y);
				}
			}
		}
	#end
	}

	static var graphic = [{"color":"f68712","path":[{"x":45,"y":12},{"x":12,"y":45},{"x":45,"y":78},{"x":78,"y":45},{"x":45,"y":12}]},{"color":"fab20b","path":[{"x":2,"y":1},{"x":45,"y":12},{"x":12,"y":45},{"x":2,"y":1}]},{"color":"f89c0e","path":[{"x":2,"y":89},{"x":12,"y":45},{"x":45,"y":78},{"x":2,"y":89}]},{"color":"f47216","path":[{"x":89,"y":1},{"x":78,"y":45},{"x":45,"y":12},{"x":89,"y":1}]},{"color":"f25c19","path":[{"x":89,"y":89},{"x":45,"y":78},{"x":78,"y":45},{"x":89,"y":89}]},{"color":"fbc707","path":[{"x":45,"y":12},{"x":2,"y":1},{"x":23,"y":1},{"x":45,"y":12}]},{"color":"fbc707","path":[{"x":45,"y":12},{"x":89,"y":1},{"x":67,"y":1},{"x":45,"y":12}]},{"color":"f68712","path":[{"x":45,"y":78},{"x":89,"y":89},{"x":67,"y":89},{"x":45,"y":78}]},{"color":"f25c19","path":[{"x":45,"y":78},{"x":2,"y":89},{"x":23,"y":89},{"x":45,"y":78}]},{"color":"fff200","path":[{"x":12,"y":45},{"x":2,"y":89},{"x":2,"y":67},{"x":12,"y":45}]},{"color":"fff200","path":[{"x":12,"y":45},{"x":2,"y":1},{"x":2,"y":23},{"x":12,"y":45}]},{"color":"f1471d","path":[{"x":78,"y":45},{"x":89,"y":89},{"x":89,"y":67},{"x":78,"y":45}]},{"color":"f1471d","path":[{"x":78,"y":45},{"x":89,"y":1},{"x":89,"y":23},{"x":78,"y":45}]}];
}
