package tldc.client.view;
import haxe.Timer;
import haxor.core.Resource;
import haxor.core.Tween;
import haxor.dom.Container;
import haxor.math.Easing.Cubic;
import js.Browser;
import js.html.Element;

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
	public var counter(get_counter, set_counter):Int;
	private function get_counter():Int { return m_counter; }
	private function set_counter(v:Int):Int 
	{ 
		m_counter = Std.int(v); 
		m_counter_field.innerText = "R$ " + FormatNumber(m_counter);
		return v;
	}
	private var m_counter : Int;
	private var m_counter_field : Element;
	
	/**
	 * CTOR.
	 */
	public function new() 
	{
		super();
		container = cast application.stage.Find("content.header");		
		m_counter_field = cast Browser.document.getElementById("header-money-counter");
		m_counter = 0;		
	}
	
	/**
	 * Shows the header.
	 */
	public function Show(p_delay:Float=0.0):Void
	{
		Tween.Add(container.layout, "py", 0.0, 0.5, p_delay, Cubic.Out);
	}
	
	/**
	 * Changes the counter using animation.
	 * @param	p_value
	 * @param	p_time
	 * @param	p_delay
	 */
	public function ChangeCounter(p_value : Int, p_time : Float = 0.5,p_delay:Float=0):Void
	{
		Tween.Add(this, "counter", p_value, p_time, p_delay,Cubic.In);
	}
	
}