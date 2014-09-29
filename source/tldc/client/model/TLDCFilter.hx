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
	static public function ByState(p_state:Array<String>) : Donation->Bool { return function(d:Donation):Bool { return p_state.indexOf(d.state) >= 0; }	}
}

/**
 * Class that filters the data in the model class.
 * @author ...
 */
class TLDCFilter extends TLDCResource
{

	private var _m : TLDCModel;
	
	/**
	 * CTOR.
	 */
	public function new() 
	{
		super();
		_m = app.model;
	}
	
	/**
	 * Filters the list of donation by a given criteria.
	 * @param	p_criteria
	 * @return
	 */
	public function Filter(p_criteria : Donation->Bool):Array<Donation>
	{
		if (_m == null) return [];
		if (p_criteria == null) return _m.donations;
		var l : Array<Donation> = [];
		for (i in 0..._m.donations.length) if (p_criteria(_m.donations[i])) l.push(_m.donations[i]);
		return l;
	}
	
	/**
	 * Returns the sum of all money spent.
	 * @return
	 */
	public function GetTotalDonations(p_criteria:Donation->Bool=null):Int
	{
		var l : Array<Donation> = Filter(p_criteria);
		var s : Int = 0;
		for (i in 0...l.length) s += l[i].value;
		return s;
	}
	
}