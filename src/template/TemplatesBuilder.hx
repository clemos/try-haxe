package template;
#if (display || macro)
import haxe.macro.Context;
import haxe.macro.Expr.Access;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FieldType;
import haxe.macro.Expr.Position;

/**
 * @author Mark Knol [http://blog.stroep.nl]
 */
class TemplatesBuilder
{
	public static var ACCESS = [Access.APublic, Access.AStatic];
	
	public static function build(url:String):Array<Field>
    {
		var fields = Context.getBuildFields();
		
		var html = sys.io.File.getContent(url);
		var ids = [];
		var sections = html.split('<template id="');
		for (section in sections)
		{
			if (section.length > 1) ids.push(section.split('"').shift());
		}
		
		for (id in ids)
		{
			fields.push({
				name: id,
				access: ACCESS,
				kind: FieldType.FVar(macro:String, macro $v{id}),
				pos: Context.makePosition( { file: "../"+url, min:1, max:2 } )
			});
		}
		return fields;
    }
}
#end
