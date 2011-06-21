package conscape.components
{
	
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.events.MouseEvent;
    import flash.text.AntiAliasType;
    import flash.text.TextFieldAutoSize;
    import flash.text.Font;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.filters.BitmapFilter;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.DropShadowFilter;

    import conscape.events.*;
    import conscape.util.MathsUtil;

    import com.modestmaps.TweenMap;
    import com.modestmaps.geo.Location;
    
    import id.core.TouchMovieClip;
    import gl.events.GestureEvent;

    public class Venue extends TouchMovieClip
    {
        private var display:*;
        private var venue_data:Object;
        private var venue_location:Location;
        private var eventData:Object;
        private var currentDataProvider:CurrentDataProvider;
        private var label:TextField;
        private var map:TweenMap;
        private var zoomToAlpha:Array = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.75, 1, 1, 1];

        public function Venue(_venue_data:Object, _currentDataProvider:CurrentDataProvider, _map:TweenMap)
        {
        	stop();
        	 	
        	buttonMode = true;
        	mouseChildren = false;
        	tabEnabled = false;        	
            // cacheAsBitmap = true;
        	
        	this.map = _map;
        	map.addEventListener(GestureEvent.GESTURE_SCALE, zoomChangedCallback);
        	
        	this.currentDataProvider = _currentDataProvider;
        	this.currentDataProvider.addEventListener(CurrentDataProviderEvent.CHANGE, dataChangeCallback);
        	this.currentDataProvider.addEventListener(CurrentDataProviderEvent.GENRE_FILTER_CHANGE, filterChangeCallback);
        	this.venue_data = _venue_data;
        	this.venue_location = new Location(
                this.venue_data["geo_lat"],
                this.venue_data["geo_long"]
            );
        	
        	// this.display = new CircleDisplay(this, this.currentDataProvider, Genre.getGenreObject());
            // this.display.setArea(3);
            this.display = new PieChart([1]);
            this.display.setRadius(1);
            
            this.display.draw();
            this.addChild(this.display);
            
            Font.registerFont(HelveticaNeueBold);
            var labelTextFormat:TextFormat = new TextFormat();
            labelTextFormat.size = 15;
            labelTextFormat.align = TextFormatAlign.CENTER;
            labelTextFormat.bold = true;
            labelTextFormat.color = 0xFFFFFF;
            labelTextFormat.kerning = true;
            labelTextFormat.font = "Helvetica Neue";
            var dropShadow:DropShadowFilter = new DropShadowFilter();
            dropShadow.color = 0x000000;
            dropShadow.blurX = 3;
            dropShadow.blurY = 3;
            dropShadow.angle = 90;
            dropShadow.alpha = 0.3;
            dropShadow.distance = 2;
            dropShadow.quality = BitmapFilterQuality.HIGH;
            this.label = new TextField();
            this.label.width = 10;
            this.label.x = -5;
            this.label.antiAliasType = flash.text.AntiAliasType.ADVANCED;
            this.label.autoSize = TextFieldAutoSize.CENTER;
            this.label.defaultTextFormat = labelTextFormat;
        	this.label.text = this.getData("name");
            this.label.filters = new Array(dropShadow);
            this.label.visible = false;
            this.addChild(this.label);
        	
        	addEventListener(MouseEvent.ROLL_OVER, bringToFront, true);
        }
        private function show():void
        {
            this.visible = true;
        }
        private function hide():void
        {
            this.visible = false;
        }
        public function isVisible():Boolean
        {
            return this.visible;
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
        public function getEventData(key:String = null):*
        {
            if (!this.eventData) return null;
            if (key) return this.eventData[key];
            return this.eventData;
        }
        public function getId():String
        {
            return this.venue_data["lastfm_id"];
        }
        public function dataChangeCallback(event:CurrentDataProviderEvent):void
        {
            this.eventData = this.currentDataProvider.getEventDataForVenue(this.getId());
            var area:Number = 3;
            if (this.eventData) {
                this.display.alpha = MathsUtil.map(this.map.getZoom(), 12, 16, 0.3, 1.0);
                area = Math.sqrt(this.eventData["totalAttendance"]) * 50;
                if (area < 3) area = 3;
                this.display.setData(this.eventData["genres"]);
            } else {
                this.display.setData(Genre.getGenreObject());
            }
            this.display.setArea(area);
            this.display.draw();
            this.label.y = this.display.getRadius() - 3;
        }
        public function filterChangeCallback(event:CurrentDataProviderEvent):void
        {
            if (event["data"] == null || (this.eventData && event["data"]["id"] == this.eventData["prominentGenre"]["id"])) {
                this.show();
            } else {
                this.hide();
            }
        }
        public function zoomChangedCallback(event:GestureEvent):void
        {
            this.label.visible = this.map.getZoom() > 14;
            this.display.alpha = MathsUtil.map(this.map.getZoom(), 12, 16, 0.3, 1.0);
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