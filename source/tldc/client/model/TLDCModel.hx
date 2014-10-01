package tldc.client.model;
import haxe.Json;
import haxor.core.Console;
import haxor.net.Web;
import haxor.platform.Types.Float32;
import tldc.client.model.TLDCFilter.Filters;
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
		party = p_party;
		state = p_state;
		value = p_value;
		position = p_position;
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
						m_current_donor = "Pequenos Doadores";
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
		filter.Reset();
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