package tldc.client.controller;
import haxe.Timer;
import haxor.core.Console;
import haxor.core.Resource;
import haxor.thread.Activity;
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
	}
	
	/**
	 * Starts the site execution.
	 */
	public function Run():Void
	{
		Console.Log("TLDCController> Run ["+Browser.location.hash+"]", 1);
		app.model.Load();
	}
	
	/**
	 * Applies the hash and executes the desired behaviour.
	 * @param	p_hash
	 */
	private function ApplyHash(p_hash:String):Void
	{
		if (p_hash == "") return;
	}
	
	private function OnDataComplete():Void
	{
		app.view.loader.Remove(0.8);
		app.view.header.Show(1.8);
		app.view.section.Show(1.8);
		ApplyHash(Browser.location.hash);
		
	}
	
	/**
	 * Updates the ui during the data loading.
	 * @param	p_data
	 * @param	p_progress
	 */
	public function OnDataLoad(p_data:String, p_progress:Float):Void 
	{ 
		app.view.loader.bar.layout.width = p_progress; 
		if (p_progress >= 1.0) OnDataComplete();	
	}
	
	/**
	 * Callback called when the browser hash changes.
	 * @param	p_event
	 */
	private function OnHashChange(p_event:Event):Void {	ApplyHash(Browser.location.hash); }
}