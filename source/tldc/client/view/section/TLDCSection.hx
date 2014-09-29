package tldc.client.view.section;
import haxor.core.Resource;
import haxor.dom.Container;

/**
 * Base class for this app sections.
 * @author ...
 */
class TLDCSection extends Resource
{

	/**
	 * Reference to this section container.
	 */
	public var container : Container;
	
	/**
	 * CTOR.
	 * @param	p_container
	 */
	public function new(p_container : Container) 
	{
		super();
		container = p_container;
		name = container.name;
	}
	
}