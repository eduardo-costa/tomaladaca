package tldc.client.controller;
import haxor.math.Mathf;
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
			case "region-heat-all":
			{
				var t : Float = 0.0;
				var vmin : Float = 10000000000000000;
				var vmax : Float = -vmin;
				for (i in 0...rl.length)
				{
					var rg : RegionState = rl[i];
					f.Reset();
					f.Filter(Filters.ByState([rg.id]));
					var v : Float = f.GetTotalDonations();					
					vmin = Mathf.Min(vmin, v);
					vmax = Mathf.Max(vmax, v);
				}
				
				for (i in 0...rl.length)
				{
					var rg : RegionState = rl[i];
					f.Reset();
					f.Filter(Filters.ByState([rg.id]));
					var v : Float = f.GetTotalDonations();					
					var r : Float = (v - vmin) / (vmax - vmin);					
					app.view.section.region.SetRegionHeat(rg.id, r);
				}
			}
		}		
	}
	
}