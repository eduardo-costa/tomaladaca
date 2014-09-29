package tldc.client.view;
import haxe.Timer;
import haxor.core.Resource;
import haxor.core.Tween;
import haxor.dom.Container;
import haxor.math.Easing.Cubic;

/**
 * Class that contains the header data.
 * @author ...
 */
class HeaderView  extends TLDCResource
{
	/**
	 * Container of the header.
	 */
	public var container : Container;
	
	/**
	 * CTOR.
	 */
	public function new() 
	{
		super();
		container = cast application.stage.Find("content.header");		
	}
	
	/**
	 * Shows the header.
	 */
	public function Show():Void
	{
		Tween.Add(container.layout, "py", 0.0, 0.5, 1.0, Cubic.Out);
	}
	
}