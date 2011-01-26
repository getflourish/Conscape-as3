package hci.events
{
	import flash.events.Event;
	
	public class DataEvent extends Event
	{
		/** Data added, removed or updated */
		public static const CHANGE:String = "change"; 
		/** Data changed due to a search */
		public static const SEARCH:String = "search";
		
		public var data:*;
		
		public function DataEvent(type:String, data:*=null, bubbles:Boolean=true)
		{
	        this.data = data;
	        super(type, bubbles);
		}	
	}

}

