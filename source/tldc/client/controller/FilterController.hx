package tldc.client.controller;
import haxor.math.Mathf;
import haxor.thread.Activity;
import tldc.client.model.TLDCFilter;
import tldc.client.TLDCResource;
import tldc.client.view.section.RegionSection.RegionState;

/**
 * Class that handles the filtering behaviour.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class FilterController extends TLDCResource
{

	/**
	 * CTOR.
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * Selects the filtering mode for all sections.
	 * @param	p_mode
	 */
	public function SetMode(p_mode : String):Void
	{
		var rl : Array<RegionState> = app.view.section.region.regions;
		var f : TLDCFilter = app.model.filter;
		
		switch(p_mode)
		{
			case "region-heat":
			{
				var t : Float = 0.0;
				var vmin : Float = 10000000000000000;
				var vmax : Float = -vmin;
				var sum : Float = 0;
				var tags : Array<String> = app.view.section.region.tags;
				
				f.Reset();
				f.Filter(Filters.ByTags(tags, true));
				f.Save();
				
				for (i in 0...rl.length)
				{
					var rg : RegionState = rl[i];		
					f.Load();
					f.Filter(Filters.ByState([rg.id]));
					var v : Float = f.GetTotalDonations();
					vmin = Mathf.Min(vmin, v);
					vmax = Mathf.Max(vmax, v);
					sum += v;
				}
				
				for (i in 0...rl.length)
				{
					var rg : RegionState = rl[i];
					f.Load();
					f.Filter(Filters.ByState([rg.id]));									
					var v : Float = f.GetTotalDonations();					
					var dv : Float = (vmax - vmin);					
					var r : Float = dv<=0.0 ? 0.0 : ((v - vmin) / dv);
					app.view.section.region.SetRegionHeat(rg.id, r);
				}
				
				app.view.header.ChangeCounter(cast sum, 1.0, 0);
			}
		}		
	}
	
	public function OnRegionFilterChange():Void
	{
		SetMode("region-heat");
	}
	
}