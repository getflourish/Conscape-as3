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
        	cacheAsBitmap = true;
        	
        	this.currentDataProvider = _currentDataProvider;
        	this.currentDataProvider.addEventListener(CurrentDataProviderEvent.CHANGE, dataChangeCallback);
        	this.venue_data = _venue_data;
        	this.venue_location = new Location(
                this.venue_data["geo_lat"],
                this.venue_data["geo_long"]
            );
        	
        	this.display = new PieChart([1, 2]);
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
            var radius:Number = 1;
            this.eventData = this.currentDataProvider.getEventDataForVenue(this.getId());
            if (this.eventData) {
                radius = 50 * (this.eventData["anzahl"] / this.currentDataProvider.getMaxNumberEvents());
            }
            this.display.setRadius(radius);
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