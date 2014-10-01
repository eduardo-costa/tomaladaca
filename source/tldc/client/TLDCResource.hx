package tldc.client;
import haxor.core.Resource;
import haxor.dom.DOMEntity;
import js.html.Element;
import js.html.HTMLCollection;

/**
 * Base class for all elements in the project.
 * @author ...
 */
class TLDCResource extends Resource
{
	/**
	 * Shortcut for this project application.
	 */
	public var app(get_app, never) : TLDC;
	private function get_app():TLDC { return cast application; }

	public function new() 
	{
		super();
	}
	
	/**
	 * 
	 * @param	p_target
	 * @param	p_callback
	 */
	public function TraverseDOM(p_target : DOMEntity,p_callback:Element->Void):Void
	{
		TraverseDOMStep(p_target.element, p_callback);
	}
	
	/**
	 * 
	 * @param	e
	 * @param	cb
	 */
	private function TraverseDOMStep(e:Element, cb:Element->Void):Void
	{
		if (e == null) return;
		if (cb != null) cb(e);
		var cl : HTMLCollection = e.children;
		for (i in 0...cl.length)
		{
			TraverseDOMStep(cast cl.item(i), cb);
		}
	}
	
	private function FormatNumber(n:Int):String
	{
		var s : String = n + "";
		var r : String = "";
		for (i in 0...s.length)
		{
			var ri : Int = s.length - 1 - i;
			if (i > 0) if ((i % 3) == 0) r = "." + r;
			r = s.charAt(ri) + r;
		}
		return r+",00";
	}
}