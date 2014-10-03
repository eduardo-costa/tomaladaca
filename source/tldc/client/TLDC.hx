package tldc.client;
import haxor.core.Application;
import haxor.core.Console;
import haxor.dom.DOMStage;
import haxor.platform.html.Entry;
import js.Browser;
import tldc.client.controller.TLDCController;
import tldc.client.model.TLDCModel;
import tldc.client.view.TLDCView;


/**
 * Main class for the TLDC application.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class TLDC extends Application
{
	//Boot method.
	static function main():Void { Entry.Initialize(); }

	/**
	 * Utility method.
	 * @param	n
	 * @return
	 */
	static public function FormatNumber(n:Int):String
	{
		var s : String = n + "";
		var r : String = "";
		for (i in 0...s.length)
		{
			var ri : Int = s.length - 1 - i;
			if (i > 0) if ((i % 3) == 0) r = "." + r;
			r = s.charAt(ri) + r;
		}
		return r+",00";
	}
	
	/**
	 * Container for all views.
	 */
	public var view : TLDCView;
	
	/**
	 * Container for all controllers.
	 */
	public var controller : TLDCController;
	
	/**
	 * Container for all models.
	 */
	public var model : TLDCModel;
	
	/**
	 * Initializes the application.
	 */
	override public function Initialize():Void 
	{
		Browser.document.body.style.removeProperty("display");
		Console.Log("TLDC> Init",1);
		
		view 		= new TLDCView();
		model		= new TLDCModel();
		controller  = new TLDCController();
		
		controller.Run();
	}
	
}