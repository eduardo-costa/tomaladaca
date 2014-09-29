package tldc.client.view;
import haxor.core.Console;
import haxor.core.Resource;

/**
 * View container.
 * @author eduardo@thelaborat.org
 */
class TLDCView extends TLDCResource
{
	/**
	 * Reference to the header view.
	 */
	public var header : HeaderView;
	
	/**
	 * Reference to the section view.
	 */
	public var section : SectionView;

	/**
	 * CTOR
	 */
	public function new() 
	{
		super();
		Console.Log("TLDCView> Init", 1);
		header = new HeaderView();
		section = new SectionView();
	}
	
}