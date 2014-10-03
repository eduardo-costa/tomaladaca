package tldc.client.view.section;
import haxor.core.Console;
import haxor.core.Tween;
import haxor.dom.Container;
import haxor.math.Color;
import haxor.math.Easing.Cubic;
import haxor.math.Mathf;
import js.Browser;
import js.html.ButtonElement;
import js.html.DivElement;
import js.html.Element;
import js.html.Event;
import js.html.HTMLCollection;
import js.html.InputElement;
import js.html.SelectElement;
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
	 * Min value in the heat map
	 */
	public var minValue(get_minValue, set_minValue):Int;
	private function get_minValue():Int { return m_minValue; }
	private function set_minValue(v:Int):Int 
	{ 
		var e : Element = cast container.GetChildByName("heat").element.firstElementChild.firstElementChild.firstElementChild;
		e.textContent = "R$ " + TLDC.FormatNumber(Std.int(v));
		m_minValue = v;
		return m_minValue;
	}
	private var m_minValue : Int;
	
	/**
	 * Max value in the heat map
	 */
	public var maxValue(get_maxValue, set_maxValue):Int;
	private function get_maxValue():Int { return m_maxValue; }
	private function set_maxValue(v:Int):Int 
	{ 
		var e : Element = cast container.GetChildByName("heat").element.firstElementChild.firstElementChild.nextElementSibling.nextElementSibling.firstElementChild;
		e.textContent = "R$ " + TLDC.FormatNumber(Std.int(v));
		m_maxValue = v;
		return m_maxValue;
	}
	private var m_maxValue : Int;
	
	/**
	 * CTOR.
	 * @param	p_container
	 */
	public function new(p_container:Container) 
	{
		super(p_container);
		Console.Log("RegionSection> Init.", 1);
		regions = [];
		tags = [];
		map = cast container.Find("map");
		minValue = maxValue = 0;
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
	 * Initializes the droplists.
	 */
	public function InitializeElements():Void
	{
		var dl : SelectElement;
		var ids : Array<String> = 
		[
		"select-position",
		"select-type",
		"select-party",
		"select-company",
		"select-person",
		"select-receptor"		
		];
		
		var opts : Array<Array<String>> = 
		[
		[],
		[],
		app.model.parties,
		app.model.companies,
		app.model.persons,
		app.model.receptors
		];
		
		for (i in 0...ids.length)
		{
			var o : Array<String> = opts[i].copy();
			var html : String = "";
			o.unshift("Todos");
			o.push("Nenhum");
			dl = cast Browser.document.getElementById(ids[i]);
			if (dl == null) { trace(ids[i]); continue; }
			for (j in 0...o.length)
			{
				var s0 : String = o[j];
				var s1 : String = s0;
				if (s0 == "Todos")  s0 = "all";
				if (s0 == "Nenhum") s0 = "none";
				html += "<option value='" + s0 + "'>" + s1 + "</option>\n";				
			}			
			if (o.length > 2) dl.innerHTML = html;			
			dl.value = "";
			dl.onchange = OnDropListChange;
		}
		
		var tc : DivElement = cast Browser.document.getElementById("tag-container");	
		tc.onclick = OnTagClick;
		
		var bt : ButtonElement = cast Browser.document.getElementById("button-tag-clear");	
		bt.onclick = function(e:Event) { tags = []; UpdateTagPanel(); app.controller.filter.OnRegionFilterChange(); };
		
	}
	
	/**
	 * Select the default tags
	 */
	public function SelectDefault():Void
	{
		tags = [];
		var rem : Array<String> = app.model.positions.copy();
		rem.remove("governador");		
		RemoveAllTags(rem);		
		UpdateTagPanel();
		app.controller.filter.OnRegionFilterChange();
	}
	
	/**
	 * 
	 * @param	l
	 */
	public function RemoveAllTags(l:Array<String>) { for (i in 0...l.length) if (tags.indexOf(l[i]) < 0) tags.push(l[i]); }
	
	/**
	 * 
	 * @param	l
	 */
	public function SelectAllTags(l:Array<String>) { for (i in 0...l.length) if (tags.indexOf(l[i]) >= 0) tags.remove(l[i]); }
	
	/**
	 * 
	 * @param	p_event
	 */
	private function OnTagClick(p_event:Event):Void
	{
		var e : Element = cast p_event.target;
		if (e.id == "tag-close")
		{
			tags.remove(e.parentElement.firstElementChild.textContent);
			UpdateTagPanel();
			app.controller.filter.OnRegionFilterChange();
		}		
	}
	
	/**
	 * Callback called when
	 * @param	p_event
	 */
	private function OnDropListChange(p_event : Event):Void
	{
		var e : SelectElement = cast p_event.target;
		var l : Array<String> = [];
		
		switch(e.id)
		{
			case "select-position": l = app.model.positions;
			case "select-type": 	l = app.model.origins;			
			case "select-party": 	l = app.model.parties;
			case "select-company": 	l = app.model.companies;
			case "select-person": 	l = app.model.persons;
			case "select-receptor": l = app.model.receptors;
		}
		
		switch(e.value)
		{
			case "all":								
				SelectAllTags(l);								
			case "none":
				RemoveAllTags(l);
				
			default:								
				SelectAllTags([e.value]);				
		}
		e.value = "";
		UpdateTagPanel();
		
		app.controller.filter.OnRegionFilterChange();
	}
	
	/**
	 * Updates the tag list in the right panel.
	 */
	private function UpdateTagPanel():Void
	{
		var tc : DivElement = cast Browser.document.getElementById("tag-container");		
		tc.innerHTML = "";		
		var html : String = "";
		for (i in 0...tags.length)
		{
			html += "<div class='panel-tag'><span>" + tags[i] + "</span><span id='tag-close'>x</span></div>";
		}
		tc.innerHTML = html;
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
	 * Updates the min/max donation values for the current filter.
	 * @param	p_min
	 * @param	p_max
	 */
	public function SetMinMax(p_min:Int, p_max:Int):Void
	{
		
		Tween.Add(this, "minValue", p_min, 0.5, Cubic.Out);
		Tween.Add(this, "maxValue", p_max, 0.5, Cubic.Out);
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
		m_chart.firstElementChild.nextElementSibling.style.width = Mathf.LerpInt(0, 100, v) + "px";
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
