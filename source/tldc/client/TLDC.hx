package tldc.client;
import haxor.core.Application;
import haxor.platform.html.Entry;


/**
 * Main class for the TLDC application.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class TLDC extends Application
{
	//Boot method.
	static function main():Void { Entry.Initialize(); }

	/**
	 * Initializes the application.
	 */
	override public function Initialize():Void 
	{
		trace("TLDC> Init");
	}
	
}