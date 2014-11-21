package template;
import haxe.macro.Expr;

/**
 * @author Mark Knol [http://blog.stroep.nl]
 */
#if !macro @:build(template.TemplatesBuilder.build("assets/templates.html")) #end
class Templates
{
	macro public static function getCopy(id:ExprOf<String>)
	{
		var identifier:String = "STUK";
		switch( id.expr ) {
			case ExprDef.EField(c, f):
				identifier = f;
			default:
		};
		var html = sys.io.File.getContent("assets/templates.html");
		var template = html.split('<template id="$identifier">').pop().split('</template>').shift();
		#if minify
		template = template.split("\n").join("").split("\r").join("").split("\t").join("");
		#end
		return haxe.macro.MacroStringTools.formatString(template, haxe.macro.Context.currentPos());
	}
}
