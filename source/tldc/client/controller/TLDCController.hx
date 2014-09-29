package tldc.client.controller;
import haxe.Timer;
import haxor.core.Console;
import haxor.core.Resource;
import haxor.thread.Activity;
import js.Browser;
import js.html.Event;
import tldc.client.model.TLDCFilter.Filters;

/**
 * Class that handles the switch between behaviours of this site.
 * @author ...
 */
class TLDCController extends TLDCResource
{
	public var path : Array<String>;

	/**
	 * CTOR.
	 */
	public function new() 	
	{
		super();
		Console.Log("TLDCController> Init", 1);
		Browser.window.onhashchange = OnHashChange;				
		path = [];
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
		var h : String = StringTools.trim(p_hash);
		h = StringTools.replace(h, "#", "");
		if (h.charAt(0) == "/") h = h.substr(1);
		if (h.charAt(h.length - 1) == "/") h = h.substr(0, h.length - 1);
		Console.Log("TLDCController> Apply Hash ["+h+"]", 2);
		var pl : Array<String> = h.split("/");
		if(pl.length>=1) app.view.section.ChangeSection(pl.shift());
		path = pl;		
	}
	
	/**
	 * Callback called when the section finished changing.
	 */
	public function OnSectionChange():Void
	{
		var c : String = app.view.section.current;
		if (c == "") return;
		Browser.location.hash = "/"+c;
	}
	
	/**
	 * Callback called when the main data files finished loading.
	 */
	private function OnDataComplete():Void
	{
		app.view.loader.Remove(0.8);
		app.view.header.Show(1.8);
		app.view.section.Show(1.8);
		Activity.Delay(2.5, function():Void {  ApplyHash(Browser.location.hash);	} );
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