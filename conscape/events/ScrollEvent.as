package hci.events
{
	public class ScrollEvent extends DataEvent
	{
		public static const SCROLL = "scroll";
		
		public function ScrollEvent(type:String, data:*=null, bubbles:Boolean=true)
		{
			super(type, data, bubbles);
		}	
	}
}

