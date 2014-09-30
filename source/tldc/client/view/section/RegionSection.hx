package tldc.client.view.section;
import haxor.core.Console;
import haxor.dom.Container;

/**
 * Section that handles data by region.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class RegionSection extends TLDCSection
{

	/**
	 * Reference to the container of the map.
	 */
	public var map : Container;
	
	/**
	 * CTOR.
	 * @param	p_container
	 */
	public function new(p_container:Container) 
	{
		super(p_container);
		Console.Log("RegionSection> Init.", 1);
		map = cast container.Find("map");
	}
	
	/**
	 * Sets the map of the section.
	 * @param	p_data
	 */
	public function SetMap(p_data:String):Void
	{
		map.element.innerHTML = p_data;
	}
	
}