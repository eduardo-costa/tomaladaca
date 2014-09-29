package tldc.client.view;
import haxor.core.Console;
import haxor.core.Tween;
import haxor.dom.Container;
import haxor.input.Input;
import haxor.input.KeyCode;
import haxor.math.Easing.Cubic;
import haxor.thread.Activity;
import tldc.client.TLDCResource;

/**
 * Class that handles the site sections.
 * @author ...
 */
class SectionView extends TLDCResource
{
	
	/**
	 * Reference to the UI container.
	 */
	public var container : Container;

	/**
	 * CTOR.
	 */
	public function new() 
	{
		super();
		container = cast app.stage.Find("content.section");
		Activity.Run(function(t:Float):Bool
		{
			if (Input.Down(KeyCode.D1)) ChangeSection("A");
			if (Input.Down(KeyCode.D2)) ChangeSection("B");
			if (Input.Down(KeyCode.D3)) ChangeSection("C");
			return true;
		});
	}
	
	/**
	 * Shows the sections.
	 */
	public function Show(p_delay:Float=0.0):Void
	{
		Tween.Add(container, "alpha", 1.0, 0.5, p_delay, Cubic.Out);
	}
	
	/**
	 * Changes the current section.
	 * @param	p_name
	 */
	public function ChangeSection(p_name : String):Void
	{
		var s : Container =  cast container.GetChildByName(p_name);
		if (s == null)
		{
			Console.Log("SectionView> Section [" + p_name+"] not found!", 1);
			return;
		}
		var v : Float = s.layout.x;				
		Tween.Add(container.layout, "x", -v, 0.5, 0.0, Cubic.Out);
	}
	
}