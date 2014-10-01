package tldc.client.model;
import tldc.client.model.TLDCModel.Donation;
import tldc.client.TLDCResource;

/**
 * Shortcut for some filtering queries.
 */
class Filters
{
	/**
	 * Filters the donation by the specified states.
	 * @param	p_state
	 * @return
	 */
	static public function ByState(p_tags:Array<String>) : Donation->Bool { return function(d:Donation):Bool { return p_tags.indexOf(d.state) >= 0; }	}
	
	/**
	 * Filters elements which have states;
	 * @return
	 */
	static public function WithState() : Donation->Bool { return function(d:Donation):Bool { return (d.state!="BR") && (d.state!=""); }	}
	
	/**
	 * Filter the donations by position.
	 * @param	p_state
	 * @return
	 */
	static public function ByPosition(p_tags:Array<String>) : Donation->Bool { return function(d:Donation):Bool { return p_tags.indexOf(d.position) >= 0; }	}
	
	/**
	 * Filter elements by tags inside the .tags field.
	 * @param	p_tags
	 * @return
	 */
	static public function ByTags(p_tags:Array<String>,p_exclude:Bool=false) : Donation->Bool 
	{ 
		return function(d:Donation):Bool 
		{ 
			for (i in 0...p_tags.length) if (d.tags.indexOf(p_tags[i]) >= 0) return !p_exclude;
			return p_exclude;
		}	
	}
	
	
	
}

/**
 * Class that filters the data in the model class.
 * @author ...
 */
class TLDCFilter extends TLDCResource
{

	private var _m : TLDCModel;
	
	private var _r : Array<Donation>;
	
	private var _s : Array<Donation>;
	
	/**
	 * CTOR.
	 */
	public function new() 
	{
		super();
		_m = app.model;	
		_s = [];
	}
	
	/**
	 * Filters the list of donation by a given criteria.
	 * @param	p_criteria
	 * @return
	 */
	public function Filter(p_criteria : Donation->Bool):Array<Donation>
	{
		if (_m == null) return [];
		if (p_criteria == null) return _r;
		var l : Array<Donation> = [];
		for (i in 0..._r.length) if (p_criteria(_r[i])) l.push(_r[i]);
		_r = l;
		return _r;
	}
	
	/**
	 * Resets the filter.
	 */
	public function Reset():Void
	{
		_r = _m.donations.copy();
	}
	
	/**
	 * Saves the current result.
	 */
	public function Save():Void
	{
		_s = _r.copy();
	}
	
	/**
	 * Loads the previous state.
	 */
	public function Load():Void
	{
		_r = _s.copy();
	}
	 
	
	/**
	 * Returns the sum of all money spent.
	 * @return
	 */
	public function GetTotalDonations(p_use_all:Bool=false):Int
	{
		var l : Array <Donation> = p_use_all ? _m.donations : _r;		
		var s : Int = 0;
		for (i in 0...l.length) s += l[i].value;
		return s;
	}
	
	
	
}