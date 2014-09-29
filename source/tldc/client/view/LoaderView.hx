package tldc.client.view;
import haxor.core.Tween;
import haxor.dom.Container;
import haxor.math.Easing.Cubic;
import haxor.thread.Activity;
import tldc.client.TLDCResource;

/**
 * Class that handles the loader UI.
 * @author ...
 */
class LoaderView extends TLDCResource
{
	/**
	 * Loader bar.
	 */
	public var bar : Container;

	/**
	 * Loader container.
	 */
	public var container : Container;
	
	/**
	 * CTOR.
	 */
	public function new() 
	{
		super();
		bar = cast app.stage.Find("content.loader.bar");
		container = cast app.stage.Find("content.loader");		
	}
	
	/**
	 * Fade out the loader and removes it.
	 */
	public function Remove(p_delay:Float=0.0):Void
	{
		Tween.Add(container, "alpha", 0.0, 0.5, p_delay, Cubic.Out);
		Activity.Delay(1.6, RemoveFromUI);
	}
	
	private function RemoveFromUI():Void
	{
		container.parent.RemoveChild(container);
	}
	
}