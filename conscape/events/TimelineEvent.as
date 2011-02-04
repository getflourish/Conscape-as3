package conscape.events
{
	public class TimelineEvent extends DataEvent
	{
		public static const RANGECHANGE = "rangechange";
		
		public function TimelineEvent(type:String, data:*=null, bubbles:Boolean=true)
		{
			super(type, data, bubbles);
		}	
	}
}

