package tldc.client.view.section;
import haxor.core.Console;
import haxor.core.Tween;
import haxor.dom.Container;
import haxor.math.Color;
import haxor.math.Easing.Cubic;
import haxor.math.Mathf;
import js.html.Element;
import js.html.Event;
import js.html.HTMLCollection;
import js.html.InputElement;
import js.html.svg.SVGElement;

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
	 * List of regions.
	 */
	public var regions : Array<RegionState>;
	
	/**
	 * Heat colors.
	 */
	public var heat : Array<Color>;
	
	/**
	 * Active filters.
	 */
	public var tags : Array<String>;
	
	/**
	 * CTOR.
	 * @param	p_container
	 */
	public function new(p_container:Container) 
	{
		super(p_container);
		Console.Log("RegionSection> Init.", 1);
		regions = [];
		map = cast container.Find("map");
		heat = 
		[
			new Color(0.0, 0.0, 1.0),
			new Color(0.0, 1.0, 1.0),
			new Color(0.0, 1.0, 0.0),
			new Color(1.0, 1.0, 0.0),
			new Color(1.0, 0.0, 0.0)
		];		
		container.Find("filters").element.onclick = OnFilterClick;
		UpdateFlags();		
	}
	
	/**
	 * Update the checked filters.
	 */
	private function UpdateFlags():Void
	{
		tags = [];		
		TraverseDOM(container.Find("filters"), function(e:Element):Void
		{
			if (e.nodeName.toLowerCase() != "input") return;
			var cb : InputElement = cast e;	
			if (!cb.checked) tags.push(cb.name);
		});		
	}
	
	/**
	 * Callback called when
	 * @param	p_event
	 */
	private function OnFilterClick(p_event : Event):Void
	{
		var e : Element = cast p_event.target;
		if (e.nodeName.toLowerCase() == "input")
		{
			var cb : InputElement = cast e;
			if (cb.name == "all")
			{	
				var ns : Element = cast cb.parentElement.nextSibling;
				TraverseDOMStep(ns, function(it:Element):Void 
				{ 
					if (it.nodeName.toLowerCase() == "input")
					{
						var ccb : InputElement = cast it;
						ccb.checked = cb.checked;					
					}
				});
			}
		}
		UpdateFlags();
		app.controller.filter.OnRegionFilterChange();
	}
	
	/**
	 * Fetches a region by its id.
	 * @param	p_id
	 * @return
	 */
	public function GetRegion(p_id : String):RegionState
	{
		for (i in 0...regions.length) if (regions[i].id == p_id) return regions[i];
		return null;
	}
	
	/**
	 * Changes the heat info of the state.
	 * @param	p_id
	 * @param	p_heat
	 */
	public function SetRegionHeat(p_id:String, p_heat : Float,p_value:Int):Void
	{
		var r : RegionState = GetRegion(p_id);
		if (r == null) return;
		var c : Color = Color.Sample(heat, p_heat);
		Tween.Add(r, "color", c, 0.5, Cubic.Out);
		Tween.Add(r, "value", p_value, 0.5, Cubic.Out);
		Tween.Add(r, "ratio", p_heat, 0.5, Cubic.Out);
	}
	
	/**
	 * Resets the map colors to white.
	 */
	public function ResetRegions():Void
	{
		var c : Color = Color.white;		
		for (i in 0...regions.length)
		{
			var r : RegionState = regions[i];
			r.value = 0;
			Tween.Add(r, "color", c, 0.5, Cubic.Out);
		}
	}
	
	/**
	 * Sets the map of the section.
	 * @param	p_data
	 */
	public function SetMap(p_data:String):Void
	{
		map.element.innerHTML = p_data;
		var l : HTMLCollection = map.element.firstElementChild.children;
		for (i in 0...l.length)
		{
			var it : Element = cast l.item(i);
			if (it.nodeName.toLowerCase() != "path") continue;
			var id : String = it.id;
			var rci : Element = null;
			var c : Container = cast container.Find("charts");
			var il : HTMLCollection = c.element.firstElementChild.nextElementSibling.children;
			for (i in 0...il.length)
			{
				var it : Element = cast il.item(i);
				var iid : String = it.firstElementChild.firstElementChild.textContent;
				if (iid == id)
				{
					rci = it;
					break;
				}
			}
			trace(rci);
			var r : RegionState = new RegionState(it, rci);			
			regions.push(r);
		}
		
	}
	
}

/**
 * Class that handles th vector art of the map.
 */
class RegionState
{
	/**
	 * Region Id.
	 */
	public var id : String;
	
	/**
	 * Region name.
	 */
	public var name : String;
	
	/**
	 * Region color.
	 */
	public var color(get_color, set_color):Color;
	private function get_color():Color { return m_color; }
	private function set_color(v:Color):Color 
	{
		m_color.SetColor(v);		
		var hex_fill : String = "#" + StringTools.hex(v.rgb,6);
		var hex_line : String = "#" + StringTools.hex(m_color.clone.Scale(0.6).rgb,6);
		m_svg.setAttribute("fill", hex_fill);
		m_svg.setAttribute("stroke", hex_line);			
		return v; 
	}
	private var m_color : Color;
	
	/**
	 * Donation value.
	 */
	public var value(get_value, set_value) : Int;
	private function get_value():Int { return m_value; }
	private function set_value(v:Int):Int 
	{ 
		m_value = v;
		m_chart.firstElementChild.nextElementSibling.textContent = "R$ "+TLDC.FormatNumber(cast Mathf.Floor(v));
		return v; 
	}
	private var m_value : Int;
	
	/**
	 * Donation Proportion.
	 */
	public var ratio(get_ratio, set_ratio) : Float;
	private function get_ratio():Float { return m_ratio; }
	private function set_ratio(v:Float):Float 
	{ 
		m_ratio = v;		
		m_chart.firstElementChild.nextElementSibling.style.width = Mathf.LerpInt(0, 190, v) + "px";
		var a : Float = Mathf.Clamp01(v / 0.05);
		var cc : Color = m_color.clone;
		cc.a = a*0.5;
		m_chart.firstElementChild.nextElementSibling.style.backgroundColor = cc.css;		
		return v; 
	}
	private var m_ratio : Float;
	
	
	/**
	 * Reference to the SVG path tag.
	 */
	private var m_svg : Element;
	
	private var m_chart : Element;

	/**
	 * Creates the state vector path container.
	 * @param	p_path
	 */
	public function new(p_svg : Element,p_chart : Element):Void
	{
		m_svg = p_svg;
		m_chart = p_chart;
		id = m_svg.id;
		m_svg.setAttribute("stroke-width", "100px");
		m_color = Color.white;
		color = Color.white;		
		value = 0;
		ratio = 0;
		switch(id)
		{ 
			case "AC": name = "Acre"; 
			case "AL": name = "Alagoas"; 
			case "AP": name = "Amapá"; 
			case "AM": name = "Amazonas"; 
			case "BA": name = "Bahia"; 
			case "CE": name = "Ceará"; 
			case "DF": name = "Distrito Federal"; 
			case "ES": name = "Espírito Santo"; 
			case "GO": name = "Goiás"; 
			case "MA": name = "Maranhão"; 
			case "MT": name = "Mato Grosso"; 
			case "MS": name = "Mato Grosso do Sul"; 
			case "MG": name = "Minas Gerais"; 
			case "PA": name = "Pará"; 
			case "PB": name = "Paraíba"; 
			case "PR": name = "Paraná"; 
			case "PE": name = "Pernambuco"; 
			case "PI": name = "Piauí"; 
			case "RJ": name = "Rio de Janeiro"; 
			case "RN": name = "Rio Grande do Norte"; 
			case "RS": name = "Rio Grande do Sul"; 
			case "RO": name = "Rondônia"; 
			case "RR": name = "Roraima"; 
			case "SC": name = "Santa Catarina"; 
			case "SP": name = "São Paulo"; 
			case "SE": name = "Sergipe"; 
			case "TO": name = "Tocantins"; 
		} 		
	}
	
}
