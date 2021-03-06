package tldc.client.model;
import haxe.Json;
import haxor.core.Console;
import haxor.net.Web;
import haxor.platform.Types.Float32;
import tldc.client.model.TLDCModel.Donation;
import tldc.client.TLDCResource;



/**
 * Template class for a tree node from the data.
 */
extern class DataTreeNode
{
	var children : Array<DataTreeNode>;	
	var value : Int;	
	var name : String;
	var parent : DataTreeNode;
}

/**
 * Class that describes a donation entry.
 */
class Donation
{
	/**
	 * Donation origin type.
	 */
	public var type : String;
	
	/**
	 * Who donated.
	 */
	public var donor : String;
	
	/**
	 * Politian position.
	 */
	public var position : String;
	
	/**
	 * Name of the position.
	 */
	public var positionName : String;
	
	/**
	 * Donation polician target.
	 */
	public var to : String;
	
	/**
	 * Politician Party
	 */
	public var party : String;
	
	/**
	 * Politician country state
	 */
	public var state : String;
	
	/**
	 * How much was invested.
	 */
	public var value : Int;
	
	/**
	 * List of relevant data.
	 */
	public var tags : Array<String>;
	
	/**
	 * All possible tags.
	 */
	public var all : Array<String>;
	
	/**
	 * Flag that indicates if the donation is selected by the current filter.
	 */
	public var selected : Bool;
	
	/**
	 * Creates a new Donation entry.
	 * @param	p_from
	 * @param	p_to
	 * @param	p_party
	 * @param	p_state
	 * @param	p_value
	 */
	public function new(p_type : String, p_donor:String, p_to:String,p_position:String, p_party:String, p_state:String, p_value:Int):Void
	{
		type = p_type;		
		donor = p_donor;
		to	 = p_to;
		selected = false;
		var i0 : Int = to.indexOf("(");		
		if (i0 >= 0)
		{
			to = to.substring(0, i0);
			to = StringTools.trim(to);
		}		
		
		party = p_party;
		state = p_state;
		value = p_value;		
		
		positionName = p_position;
		position = p_position;		
		position = StringTools.replace(position, " ", "-").toLowerCase();
		if (position == "presidente") state = "DF";
		if (state == "BR") state = "DF";
		if (position.indexOf("comitê") >= 0) position = "comite";		
		
		if(positionName.indexOf("Comitê")<0) to = positionName+" - "+to;
		
		to += " (" + party;
		to += state == "" ? "" : ("/" + state);
		to +=  ")";
		
		tags = [type, donor, party, state, position,to];		
		
		
	}
}

/**
 * Class that handles the application data.
 * @author ...
 */
class TLDCModel extends TLDCResource
{
	/**
	 * Original data tree.
	 */
	public var tree : DataTreeNode;
	
	/**
	 * Array of donations parsed from the data tree.
	 */
	public var donations : Array<Donation>;
	
	/**
	 * List of donation origins.
	 */
	public var origins : Array<String>;
	
	/**
	 * List of political parties.
	 */
	public var parties : Array<String>;
	
	/**
	 * List of political positions.
	 */
	public var positions : Array<String>;
	
	/**
	 * List of donation receptors.
	 */
	public var receptors : Array<String>;
	
	/**
	 * Donor companies
	 */
	public var companies : Array<String>;
	
	/**
	 * Donor persons.
	 */
	public var persons : Array<String>;
	
	/**
	 * List of states.
	 */
	public var states : Array<String>;
	
	/**
	 * Reference to the filter class.
	 */
	public var filter : TLDCFilter;
	
	
	
	/**
	 * Current donation type in the parse process.
	 */
	private var m_current_type : String;
	
	/**
	 * Current donor in the parse process.
	 */
	private var m_current_donor : String;
	
	/**
	 * Current target party for donation.
	 */
	private var m_current_party : String;
	
	/**
	 * Overall progress of the file loading.
	 */
	public var progress(get_progress, never):Float;
	private function get_progress():Float
	{ 
		return (m_p0 + m_p1) * 0.5; 
	}
	
	
	private var m_p0 : Float;
	private var m_p1 : Float;
	
	/**
	 * CTOR.
	 */
	public function new() 
	{
		super();				
	}
	
	/**
	 * Loads the initial data.
	 */
	public function Load():Void
	{
		Console.Log("TLDCModel> Load data.", 1);
		filter = new TLDCFilter();
		m_p0 = 0;
		m_p1 = 0;
		Web.Load("data/data-tree-2014.json", OnDataLoad);
		Web.Load("image/map.xml", OnMapLoad);
	}
	
	/**
	 * Process the nodes and organize all donations in a list.
	 * @param	p_node
	 * @param	p_parent
	 */
	private function ProcessNode(p_node : DataTreeNode,p_parent : DataTreeNode):Void
	{
		if (p_node.name == null) return;
		
		var ppn : String = p_node.parent == null ? "" : (p_node.parent.parent == null ? "" : p_node.parent.parent.name); 
		var pn : String = p_node.parent == null ? "" : p_node.parent.name;
		var n : String = p_node.name;		
		var t : String = n.toLowerCase();
		var s : String = "";
		var st : String = "";
		var is_party : Bool=false;
		
		if (p_node.value != null)
		{			
			if (n.indexOf("(") >= 0)
			{				
				var sttk : Array<String> = n.split("(");
				if (sttk.length >= 1) s = sttk[1];
				s  = StringTools.replace(s,  ")", "");
				st = StringTools.trim(s).toUpperCase();								 				
			}
			var v : Int = p_node.value;			
			var d : Donation = new Donation(m_current_type,m_current_donor, n,pn, m_current_party, st, v);
			donations.push(d);
		}
		else
		{
			
			if (t.indexOf("fundo") >= 0) 	{ m_current_type = "fundo"; return; }
			if (t.indexOf("empresas") >= 0) { m_current_type = "empresa"; return; }
			if (t.indexOf("pessoa") >= 0) 	{ m_current_type = "pessoa"; return; }
			
			switch(m_current_type)
			{
				case "pessoa","empresa":
										
					if (ppn.toLowerCase().indexOf("grandes") >= 0) m_current_party = StringTools.trim(n).toUpperCase(); 					
					if (pn.toLowerCase().indexOf("pequenos") >= 0)
					{
						if (m_current_type == "empresa")
						{
							m_current_donor = "Pequenas Empresas";
						}
						else
						{
							m_current_donor = "Pequenos Doadores";
						}						
						m_current_party = StringTools.trim(n).toUpperCase();
					}					
					if (pn.toLowerCase().indexOf("grandes") >= 0) m_current_donor = StringTools.trim(n);					
				
				case "fundo":
					if (pn.indexOf("fundo") >= 0) m_current_party = StringTools.trim(n).toUpperCase(); 
			}
			
		}
	}
	
	/**
	 * Callback to handle the load of the SVG map.
	 * @param	p_data
	 * @param	p_progress
	 */
	private function OnMapLoad(p_data : String, p_progress:Float32):Void
	{
		m_p1 = p_progress;
		app.controller.OnMapLoad(p_data, progress);
	}
	
	/**
	 * Callback to handle the data load process.
	 * @param	p_data
	 * @param	p_progress
	 */
	private function OnDataLoad(p_data : String, p_progress:Float32):Void
	{
		if (p_data != null)
		{
			tree = cast Json.parse(p_data);
			TraverseTreeData(tree,null,AdjustTree);
			Parse();
		}		
		m_p0 = p_progress;
		app.controller.OnDataLoad(p_data, progress);
	}
	
	/**
	 * Parse the current tree data.
	 */
	private function Parse():Void
	{		
		donations = [];		
		TraverseTreeData(tree, null, ProcessNode);
		var sum :Int = 0;
		for (i in 0...donations.length) sum += donations[i].value;
		
		parties = [];
		positions = [];
		receptors = [];
		companies = [];
		parties = [];
		persons = [];		
		origins = [];
		states = [];
		//var s : String = "";
		for (i in 0...donations.length)
		{	
			var s :String;
			var t : String = donations[i].type;
			s = donations[i].party;		if (s != "") if (parties.indexOf(s) < 0) parties.push(s);
			s = donations[i].position;	if (s != "") if (positions.indexOf(s) < 0) positions.push(s);
			s = donations[i].to;		if (s != "") if (receptors.indexOf(s) < 0) receptors.push(s);
			s = donations[i].type;		if (s != "") if (origins.indexOf(s) < 0) origins.push(s);
			s = donations[i].state;		if (s != "") if (states.indexOf(s) < 0) states.push(s);
			s = donations[i].donor;		
			if (t == "empresa") if (s != "") if (companies.indexOf(s) < 0) companies.push(s);
			if (t == "pessoa")  if (s != "") if (persons.indexOf(s) < 0) persons.push(s);
			
			
			
			
		}
		/*
		for (i in 0...companies.length)
		{
			var s : String = companies[i];
			
			if (s.indexOf("-") >= 0) companies[i] = s.split("-")[0];
			
			companies[i] = Compact(companies[i], "Distribuidora", "Distrib");
			companies[i] = Compact(companies[i], "Recursos Humanos", "RH");
			companies[i] = Compact(companies[i], "Sistemas", "Sist");
			companies[i] = Compact(companies[i], "Sistema", "Sist");
			companies[i] = Compact(companies[i], "Administração", "Admin");
			companies[i] = Compact(companies[i], "Companhia", "Cia");
			companies[i] = Compact(companies[i], "Mobiliarios", "Mob");
			companies[i] = Compact(companies[i], "Rodoviárias", "Rod");
			companies[i] = Compact(companies[i], "Alimentos", "Alim");
			companies[i] = Compact(companies[i], "Servicos", "Serv");
			companies[i] = Compact(companies[i], "Minas Gerais", "MG");
			companies[i] = Compact(companies[i], "Comercio", "Com");
			companies[i] = Compact(companies[i], "Trabalho", "Trab");
			companies[i] = Compact(companies[i], "Federação", "Fed");
			companies[i] = Compact(companies[i], "Telecomunicacao", "Telecom");
			companies[i] = Compact(companies[i], "Imobiliarios", "Imob");
			companies[i] = Compact(companies[i], "Industria", "Ind");
			
		}
		//*/
		
		companies.sort(function(a:String, b:String):Int { if (a.indexOf("Pequenos")>=0) return 1; if (b.indexOf("Pequenos")>=0) return -1; return a < b ? -1 : 1; } );		
		persons.sort(function(a:String, b:String):Int { if (a.indexOf("Pequenos") >= 0) return 1; if (b.indexOf("Pequenos") >= 0) return -1; return a < b ? -1 : 1; } );
		
		receptors.sort(function(a:String, b:String):Int {  return a < b ? -1 : 1; } );
		parties.sort(function(a:String, b:String):Int { return a < b ? -1 : 1; } );
		
		filter.Initialize();
	}
	
	private function Compact(s:String, f:String, t:String):String
	{
		if (s.indexOf(f) >= 0) return StringTools.replace(s, f, t+".");
		return s;
	}
	
	/**
	 * Traverse 1 step in the tree data.
	 * @param	p_node
	 * @param	p_parent
	 * @param	p_callback
	 */
	private function TraverseTreeData(p_node : DataTreeNode,p_parent : DataTreeNode,p_callback:DataTreeNode->DataTreeNode->Void):Void
	{
		p_callback(p_node,p_parent);		
		if (p_node.children == null) return;
		for (i in 0...p_node.children.length) TraverseTreeData(p_node.children[i],p_node,p_callback);
	}
	
	private function AdjustTree(n:DataTreeNode, p:DataTreeNode):Void { n.parent = p; }
}