package tldc.client.controller;
import haxe.Timer;
import haxor.core.Console;
import haxor.core.Resource;
import js.Browser;
import js.html.Event;

/**
 * Class that handles the switch between behaviours of this site.
 * @author ...
 */
class TLDCController extends TLDCResource
{

	/**
	 * CTOR.
	 */
	public function new() 	
	{
		super();
		Console.Log("TLDCController> Init", 1);
		Browser.window.onhashchange = OnHashChange;
		
		app.view.header.Show();
		
		Timer.delay(Run, 200);		
	}
	
	/**
	 * Starts the site execution.
	 */
	private function Run():Void
	{
		Console.Log("TLDCController> Run ["+Browser.location.hash+"]", 1);
		ApplyHash(Browser.location.hash);
	}
	
	/**
	 * Applies the hash and executes the desired behaviour.
	 * @param	p_hash
	 */
	private function ApplyHash(p_hash:String):Void
	{
		if (p_hash == "") return;
	}
	
	private function OnHashChange(p_event:Event):Void {	ApplyHash(Browser.location.hash); }
}