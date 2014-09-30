package tldc.client.view;
import haxe.Timer;
import haxor.core.Resource;
import haxor.core.Tween;
import haxor.dom.Container;
import haxor.math.Easing.Cubic;

/**
 * Class that contains the footer data.
 * @author ...
 */
class FooterView  extends TLDCResource
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
		container = cast application.stage.Find("content.footer");		
	}
	
	/**
	 * Shows the header.
	 */
	public function Show(p_delay:Float=0.0):Void
	{
		Tween.Add(container.layout, "py", 1.0, 0.5, p_delay, Cubic.Out);
	}
	
}