package tldc.client;
import haxor.core.Resource;

/**
 * Base class for all elements in the project.
 * @author ...
 */
class TLDCResource extends Resource
{
	/**
	 * Shortcut for this project application.
	 */
	public var app(get_app, never) : TLDC;
	private function get_app():TLDC { return cast application; }

	public function new() 
	{
		super();
	}
	
	private function FormatNumber(n:Int):String
	{
		var s : String = n + "";
		var r : String = "";
		for (i in 0...s.length)
		{
			var ri : Int = s.length - 1 - i;
			if (i > 0) if ((i % 3) == 0) r = "." + r;
			r = s.charAt(ri) + r;
		}
		return r+",00";
	}
}