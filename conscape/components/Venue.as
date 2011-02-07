package conscape.components
{
	
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.events.MouseEvent;

    import conscape.events.*;

    import com.modestmaps.geo.Location;
    
    import id.core.TouchMovieClip;

    public class Venue extends TouchMovieClip
    {
           
        private var display:PieChart;
        private var venue_data:Object;
        private var venue_location:Location;
        private var eventData:Object;
        private var currentDataProvider:CurrentDataProvider;

        public function Venue(_venue_data:Object, _currentDataProvider:CurrentDataProvider)
        {
        	stop();
        	 	
        	buttonMode = true;
        	mouseChildren = false;
        	tabEnabled = false;        	
        	//cacheAsBitmap = true;
        	
        	this.currentDataProvider = _currentDataProvider;
        	this.currentDataProvider.addEventListener(CurrentDataProviderEvent.CHANGE, dataChangeCallback);
        	this.venue_data = _venue_data;
        	this.venue_location = new Location(
                this.venue_data["geo_lat"],
                this.venue_data["geo_long"]
            );
        	
        	this.display = new PieChart([1]);
            this.display.setRadius(1);
            this.display.draw();
            this.addChild(this.display);
        	
        	addEventListener(MouseEvent.ROLL_OVER, bringToFront, true);
        }
        public function getLocation():Location
        {
            return this.venue_location;
        }
        public function getData(key:String = null):*
        {
            if (key) return this.venue_data[key];
            return this.venue_data;
        }
        public function getId():String
        {
            return this.venue_data["lastfm_id"];
        }
        public function dataChangeCallback(event:CurrentDataProviderEvent):void
        {
            this.eventData = this.currentDataProvider.getEventDataForVenue(this.getId());
            if (this.eventData) {
                this.display.setRadius(50 * (this.eventData["numberEvents"] / event.data.maxNumberEvents));
                var chart_data:Array = [];
                for each(var genreName:String in Genre.ORDER) {
                    chart_data.push(eventData["genres"][genreName]["count"]);
                }
                this.display.setData(chart_data);
            } else {
                this.display.setRadius(1);
                this.display.setData([1]);
            }
             this.display.draw();
        }
        protected function bringToFront(e:MouseEvent):void
        {
       		parent.swapChildrenAt(parent.getChildIndex(this), parent.numChildren - 1);
        }
        override public function toString():String
        {
        	return '[Venue] ' + this.venue_data["name"];
        }
    }
}