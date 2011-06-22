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
    import flash.utils.Dictionary;

    import conscape.events.*;
    import conscape.util.MathsUtil;

    import com.modestmaps.TweenMap;
    import com.modestmaps.geo.Location;
    
    import id.core.TouchMovieClip;
    import gl.events.GestureEvent;
    
    import com.maclema.mysql.Statement;
    import com.maclema.mysql.Connection;
    import com.maclema.mysql.ResultSet;
    import com.maclema.mysql.MySqlToken;
    import com.maclema.mysql.events.MySqlEvent;
    import com.maclema.mysql.events.MySqlErrorEvent;
    
    import gs.TweenLite;

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
        	
        	this.display = new CircleDisplay(this, this.currentDataProvider);
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
        public function getTopArtists(callback:Function, startDate:Date = null, endDate:Date = null):void
        {
            var venue_id = this.venue_data["lastfm_id"];
            var con:Connection = this.currentDataProvider.getConnection();
            if (startDate && endDate) {
                var startdate:String = MathsUtil.convertASDateToMySQLTimestamp(startDate);
                var enddate:String = MathsUtil.convertASDateToMySQLTimestamp(endDate);

                var query:String = [
                    "SELECT artists",
                    "FROM events",
                    "WHERE startdate BETWEEN '"+startdate+"' AND '"+enddate+"' AND lastfm_venue_id = '"+venue_id+"'"
                ].join(" ");
            } else {
                var query:String = [
                    "SELECT artists",
                    "FROM events",
                    "WHERE lastfm_venue_id = '"+venue_id+"'"
                ].join(" ");
            }
            var st:Statement = con.createStatement(); 
            var token:MySqlToken = st.executeQuery(query);
            token.addEventListener(MySqlErrorEvent.SQL_ERROR, function(event:MySqlErrorEvent)
            {
                trace(event.msg);
            });
            token.addEventListener(MySqlEvent.RESULT, function(event:MySqlEvent)
            {
                var artistCounts:Dictionary = new Dictionary();
                for each(var item:* in event.resultSet.getRows()) {
                    for each(var artistName:String in String(item["artists"]).split(";;;")) {
                        if (artistCounts[artistName] == null) artistCounts[artistName] = 0;
                        artistCounts[artistName] += 1;
                    }
                }
                var artists:Array = [];
                for(var key:String in artistCounts) {
                    artists.push({
                        "name": key,
                        "count": artistCounts[key]
                    });
                }
                artists.sortOn(["count", "name"], [Array.DESCENDING, Array.CASEINSENSITIVE]);
                if (callback != null) callback(artists);
            });
        }
        private function show():void
        {
            this.visible = true;
            TweenLite.to(this, 1, {alpha: 1});
        }
        private function hide():void
        {
            TweenLite.to(this, 1, {alpha: 0, onComplete: makeInvisible});
        }
        private function makeInvisible() {
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
            this.display.alpha = MathsUtil.map(this.map.getZoom(), 12, 16, 0.3, 1.0);
            this.display.draw();
            this.label.y = this.display.getRadius() - 3;
        }
        public function filterChangeCallback(event:CurrentDataProviderEvent):void
        {
            if (this.eventData && event["data"][this.eventData["prominentGenre"]["id"]]) {
                this.show()
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