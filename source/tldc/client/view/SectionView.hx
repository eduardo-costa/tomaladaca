package tldc.client.view;
import haxor.core.Console;
import haxor.core.Tween;
import haxor.dom.Container;
import haxor.input.Input;
import haxor.input.KeyCode;
import haxor.math.Easing.Cubic;
import haxor.thread.Activity;
import tldc.client.TLDCResource;
import tldc.client.view.section.RegionSection;
import tldc.client.view.section.TLDCSection;

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
	 * List of sections.
	 */
	public var sections : Array<TLDCSection>;

	/**
	 * Current section.
	 */
	public var current : TLDCSection;
	
	/**
	 * Reference to the region section.
	 */
	public var region : RegionSection;
	
	/**
	 * CTOR.
	 */
	public function new() 
	{
		super();
		container = cast app.stage.Find("content.section");		
		sections = [];
		current = null;
		
		var c : Container;
		var s : TLDCSection;
		
		c = cast container.Find("region");
		if (c != null) { s = new RegionSection(c); sections.push(s); current = s; region = cast s; }
		
	}
	
	/**
	 * Shows the sections.
	 */
	public function Show(p_delay:Float=0.0):Void
	{
		Tween.Add(container, "alpha", 1.0, 0.5, p_delay, Cubic.Out);
	}
	
	/**
	 * Returns the section by name.
	 * @param	p_name
	 * @return
	 */
	public function GetSection(p_name:String):TLDCSection
	{
		for (i in 0...sections.length) if (sections[i].name == p_name) return sections[i];
		return null;
	}
	
	/**
	 * Changes the current section.
	 * @param	p_name
	 */
	public function ChangeSection(p_name : String):Void
	{
		if (current != null) if (p_name == current.name) return;
		var s : TLDCSection = GetSection(p_name);
				
		if (s == null)
		{
			Console.Log("SectionView> Section [" + p_name+"] not found!", 1);
			return;
		}		
		current = s;
		var v : Float = s.container.layout.x;				
		Tween.Add(s.container.layout, "x", -v, 0.5, 0.0, Cubic.Out);
		Activity.Delay(0.6, app.controller.OnSectionChange);
	}
	
}