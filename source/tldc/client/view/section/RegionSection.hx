package tldc.client.view.section;
import haxor.core.Console;
import haxor.core.Tween;
import haxor.dom.Container;
import haxor.math.Color;
import haxor.math.Easing.Cubic;
import js.html.Element;
import js.html.HTMLCollection;
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
	public function SetRegionHeat(p_id:String, p_heat : Float):Void
	{
		var r : RegionState = GetRegion(p_id);
		var c : Color = Color.Sample(heat, p_heat);
		Tween.Add(r, "color", c, 0.5, Cubic.Out);
	}
	
	/**
	 * Resets the map colors to white.
	 */
	public function ResetColors():Void
	{
		var c : Color = Color.white;		
		for (i in 0...regions.length)
		{
			var r : RegionState = regions[i];
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
			var r : RegionState = new RegionState(it);			
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
		m_path.setAttribute("fill", hex_fill);
		m_path.setAttribute("stroke", hex_line);
		return v; 
	}
	private var m_color : Color;
	
	/**
	 * Reference to the SVG path tag.
	 */
	private var m_path : Element;

	/**
	 * Creates the state vector path container.
	 * @param	p_path
	 */
	public function new(p_path : Element):Void
	{
		m_path = p_path;
		id = m_path.id;
		m_path.setAttribute("stroke-width", "100px");
		m_color = Color.white;
		color = Color.white;		
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
