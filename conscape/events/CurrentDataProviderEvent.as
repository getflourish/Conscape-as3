package conscape.events
{
	public class CurrentDataProviderEvent extends DataEvent
	{
		public static const CHANGE = "change";
		public static const GENRE_FILTER_CHANGE = "genreFilterChange";
		
		public function CurrentDataProviderEvent(type:String, data:*=null, bubbles:Boolean=true)
		{
			super(type, data, bubbles);
		}	
	}
}

