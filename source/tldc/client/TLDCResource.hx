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
	
}