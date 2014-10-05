package tldc.client.model;
import haxor.core.Console;
import haxor.math.Mathf;
import tldc.client.model.TLDCModel.Donation;
import tldc.client.TLDCResource;


/**
 * Class that filters the data in the model class.
 * @author ...
 */
class TLDCFilter extends TLDCResource
{
	/**
	 * Total donations for the current query.
	 */
	public var total : Int;
	
	/**
	 * Smallest donation for the current query.
	 */
	public var min : Int;
	
	/**
	 * Biggest donation for the current query.
	 */
	public var max : Int;
	
	/**
	 * Total donations by state.
	 */
	public var totalByState : Map<String,Int>;
	
	/**
	 * Smallest donations by state.
	 */
	public var minByState : Map<String,Int>;
	
	/**
	 * Smallest donations by state.
	 */
	public var maxByState : Map<String,Int>;

	/**
	 * Current query.
	 */
	public var query : Array<String>;
	
	/**
	 * All possible values.
	 */
	public var sample : Array<String>;
	
	private var _m : TLDCModel;
	
	private var _d : Array<Donation>;
	
	/**
	 * CTOR.
	 */
	public function new() 
	{
		super();
		
		_m = app.model;			
		totalByState = new Map<String,Int>();
		minByState = new Map<String,Int>();
		maxByState = new Map<String,Int>();
		total = 0;
		min = 0;
		max = 0;
		query = [];
	}
	
	/**
	 * Initializes the internal data.
	 */
	public function Initialize():Void
	{
		Console.Log("TLDCFilter> Initialize", 1);
		var l : Array<String>;
		sample = [];		
		
		sample = sample.concat(app.model.positions);
		sample = sample.concat(app.model.origins);
		sample = sample.concat(app.model.companies);
		sample = sample.concat(app.model.parties);
		sample = sample.concat(app.model.persons);
		sample = sample.concat(app.model.receptors);		
				
		Clear();		
		
	}
	
	/**
	 * Calls the default query
	 */
	public function DefaultQuery():Void
	{
		var dq : Array<String> = [];		
		dq = dq.concat(["governador"]);
		dq = dq.concat(app.model.parties);
		dq = dq.concat(app.model.persons);
		dq = dq.concat(app.model.origins);
		dq = dq.concat(app.model.receptors);
		dq = dq.concat(app.model.companies);		
		AddQuery(dq);
	}
	
	/**
	 * Add elements to the query.
	 * @param	p_tags
	 */
	public function AddQuery(p_tags : Array<String>):Void { UpdateQuery(p_tags, false); }
	
	/**
	 * Remove elements from query.
	 * @param	p_tags
	 */
	public function RemoveQuery(p_tags:Array<String>):Void { UpdateQuery(p_tags, true);}
	
	/**
	 * 
	 * @param	p_tags
	 * @param	p_remove
	 */
	private function UpdateQuery(p_tags:Array<String>, p_remove : Bool):Void
	{
		Console.Log("TLDCFilter> Query remove[" + p_remove+"]", 1);
		if(Console.verbose>=3) trace(p_tags);
		
		for (i in 0...p_tags.length)
		{
			var t : String = p_tags[i];
			var qi : Int = query.indexOf(t);
			var si : Int = sample.indexOf(t);
			if (p_remove)
			{
				if (qi >= 0)	{ query[qi] = query[query.length - 1]; query.pop(); }
				if (si < 0)		sample.push(t);
			}
			else
			{
				if (si >= 0)	{ sample[si] = sample[sample.length - 1]; sample.pop(); }
				if (qi < 0)		query.push(t);
			}			
		}				
		Select();		
	}
	
	/**
	 * Filters the list of donation by a given criteria.
	 * @param	p_criteria
	 * @return
	 */
	public function Select():Void
	{
		if (_m == null) return;
		_d = _m.donations;
		var res : Array<Donation> = [];
		for (i in 0..._d.length)
		{
			var tl : Array<String> = _d[i].tags;			
			_d[i].selected = true;
			for (j in 0...tl.length)
			{
				if (sample.indexOf(tl[j]) >= 0) 
				{ 
					_d[i].selected = false; 
					break; 
				}
			}
			if(_d[i].selected) res.push(_d[i]);
		}		
		trace(res);
		UpdateDonations();
	}
	
	/**
	 * Resets the filter.
	 */
	public function Clear():Void
	{
		UpdateQuery(query.copy(), true);
	}
	
	
	
	/**
	 * Updates the donation count for the current filter.
	 */
	private function UpdateDonations():Void
	{
		var found : Int = 0;
		total = 0;		
		min = 900000000;
		max = -min;
		for (i in 0..._m.states.length) totalByState.set(_m.states[i], 0);
		
		_d = _m.donations;
		for (i in 0..._d.length)
		{
			if (!_d[i].selected) continue;
			found++;
			var v : Int = _d[i].value;
			var st : String = _d[i].state;			
			total += v;
			var sv : Int = totalByState.exists(st) ? totalByState.get(st) : 0;
			totalByState.set(st, sv + v);			
		}
		
		for (st in _m.states)
		{
			var v : Int = totalByState.get(st);
			min = cast Mathf.Min(min, v);
			max = cast Mathf.Max(max, v);			
		}
		
		if (found<=0)
		{			
			min = max = 0;
		}
		
		Console.Log("TLDCFilter> Query Found [" + found + "] results min["+min+"] max["+max+"] total["+total+"]");		
		if (Console.verbose >= 3) trace(this);
		app.controller.OnQueryChange(this);
	}
	
	
}