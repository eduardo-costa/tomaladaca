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
}

/**
 * Class that describes a donation entry.
 */
class Donation
{
	/**
	 * Donation origin.
	 */
	public var from : String;
	
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
	public function new(p_from : String, p_to:String, p_party:String, p_state:String, p_value:Int):Void
	{
		from = p_from;
		to	 = p_to;
		party = p_party;
		state = p_state;
		value = p_value;
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
	 * Total donations.
	 */
	public var total : Int;
	
	/**
	 * Current donation origin in the parse process.
	 */
	private var m_current_origin : String;
	
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
		Web.Load("data/data-tree-2014.json", OnDataLoad);
	}
	
	private function ProcessNode(p_node : DataTreeNode):Void
	{
		if (p_node.name == null) return;
		
		var n : String = p_node.name;
		var o : String = n.toLowerCase();
		
		if (p_node.value != null)
		{
			var v : Int = p_node.value;
			total += v;
			var d : Donation = new Donation(m_current_origin, n, "", "", v);
			donations.push(d);
		}
		else
		{
			if (o.indexOf("fundo") >= 0) 	m_current_origin = "fundo-partidario";
			if (o.indexOf("empresas") >= 0) m_current_origin = "empresa";
			if (o.indexOf("pessoa") >= 0) 	m_current_origin = "pessoa";
		}
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
			Parse();
		}		
		app.controller.OnDataLoad(p_data, p_progress);
	}
	
	/**
	 * Parse the current tree data.
	 */
	private function Parse():Void
	{
		trace(tree);
		total = 0;
		donations = [];
		ParseTree(tree);
		trace("R$ " + total);
		trace(donations);
	}
	
	private function ParseTree(p_node : DataTreeNode):Void
	{
		ProcessNode(p_node);
		for (i in 0...p_node.children.length)
		{
			trace(p_node.children[i]);
			//ParseTree(p_node.children[i]);
		}
	}
	
}