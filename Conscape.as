package
{

    import com.adobe.serialization.json.*;

    import com.maclema.mysql.Statement;
    import com.maclema.mysql.Connection;
    import com.maclema.mysql.ResultSet;
    import com.maclema.mysql.MySqlToken;
    import com.maclema.mysql.events.MySqlEvent;
    import com.maclema.mysql.events.MySqlErrorEvent;

    import com.modestmaps.Map;
    import com.modestmaps.TweenMap;
    import com.modestmaps.events.MapEvent;
    import com.modestmaps.events.MarkerEvent;
    import com.modestmaps.geo.Location;
    import com.modestmaps.mapproviders.*;
    import com.modestmaps.mapproviders.microsoft.*;

    import conscape.components.*;
    import conscape.events.*;
    import conscape.util.*;

    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.TimerEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.ColorTransform;
    import flash.text.TextField;
    import flash.text.TextFormat;

    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLVariables;
    import flash.utils.Timer;
    import flash.utils.Dictionary;

    import id.core.Application;
    import id.core.TouchSprite;
    import id.tracker.Tracker;

    import gl.events.TouchEvent;
    import gl.events.GestureEvent;

    import gs.TweenLite;

    import nl.demonsters.debugger.MonsterDebugger;

    public class Conscape extends Application {

        private var debugger:MonsterDebugger;

        private const PADDINGRIGHT:int = 100;
        private const BOTTOMPADDING:int = 300;
        private const TIMELINEPADDINGLEFT = 20;
        private const TIMELINEPADDINGTOP = 50;
        private const TIMELINEHEIGHT = 150;
        private var auto:Boolean = false;
        private var cachedMarkers:Dictionary;
        private var con:Connection;
        private var currentScale = 12;
        private var dates:ResultSet;
        private var lastScaleValue:Number = 0;
        private var map:TweenMap;
        private var markers:Dictionary;
        private var maxEvents = 0;
        private var myTimer:Timer;
        private var timeline:Timeline;
        private var tooltip:Tooltip;
        private var zooming:Boolean = false;
        private var zoomPoint:Point;

        private var venues:Dictionary;
        private var currentDataProvider:CurrentDataProvider;

        private var genreChartBar:GenreChartBar;
        
        private var fader:Shape;
        private var black:Boolean = true;

        public function Conscape()
        {
            this.licenseKey = "18AF7FE030741A38BE7FFBFDAC9590A4E1B66841B6";
            this.settingsPath = "application.xml";
			super();
            
            var fps:FPSCounter = new FPSCounter();
            fps.x = stage.stageWidth - 100;
            addChild(fps);

        	// Falls die Fenstergröße verändert wird (später unnötig aber mal gut zu sehen, wie es geht)
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.addEventListener(Event.RESIZE, onResize);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, pause);

            this.markers = new Dictionary(true);

            createMap();
            connectToDatabase();
            createTimeline();
            currentDataProvider = new CurrentDataProvider(timeline, con);
            loadVenues();

            this.genreChartBar = new GenreChartBar(stage.stageHeight - 100 - TIMELINEHEIGHT, 75, currentDataProvider);
            this.genreChartBar.x = stage.stageWidth - 150;
            this.genreChartBar.y = 50;

            this.addChild(this.genreChartBar);
            
            // fader
            this.fader = new Shape();
            this.fader.graphics.beginFill(0x000000, 100);
            this.fader.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            this.fader.graphics.endFill();
            
            stage.addChild(fader);
        }
        private function pause (event:KeyboardEvent):void
        {
            if (auto) {
                if (myTimer.running) {
                    myTimer.stop();
                } else {
                    myTimer.start();
                }
            }
        }
        private function createMap():void
        {
            // Erstellt eine Karte mit Berlin als Zentrum
            // 999 night
            // 30059
            // Simple beige 30285
            // 19816 grau
            // 31429 conscape
            map = new TweenMap(
                stage.stageWidth,
                stage.stageHeight - TIMELINEHEIGHT,
                true,
            	new CloudmadeProvider(10,18,"c1862c9125834b9fa203084d73eba088", 31429),
            	new Location(52.522, 13.405),
                currentScale);
            map.x = map.y = 0;
            addChild(map);

            map.addEventListener(TouchEvent.TOUCH_TAP, onMapTap);
            map.addEventListener(MarkerEvent.MARKER_TAP, onMarkerTap);
            map.addEventListener(GestureEvent.GESTURE_SCALE, onLocationZoom);
            map.addEventListener(TouchEvent.TOUCH_MOVE, onMapMove);

            map.blobContainerEnabled = true;
            map.markerClip.markerSortFunction = null;

            // Tooltip
            tooltip = new Tooltip();
            addChild(tooltip);
            
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);

            onResize();
        }
        private function createTimeline():void
        {
            timeline = new Timeline([], stage.stageWidth, TIMELINEHEIGHT);

            var st:Statement = con.createStatement();
            var token:MySqlToken = st.executeQuery("SELECT COUNT(startdate) AS anzahl, DATE_FORMAT(startdate, '%Y-%m-%d') AS startdate FROM events WHERE YEAR(startdate) > 2005 GROUP BY YEAR(startdate), MONTH(startdate), DAY(startdate)");
            token.addEventListener(MySqlErrorEvent.SQL_ERROR, onError);
            token.addEventListener(MySqlEvent.RESULT, function(event:MySqlEvent)
            {
                var rs:ResultSet = event.resultSet;
                timeline.setData(rs.getRows())
                timeline.addEventListener(TimelineEvent.RANGECHANGE, function(event:TimelineEvent) {

                    timeline.setTitle("Konzerte vom " + MathsUtil.getBeautifulDate(event.data.startdate) + "—" + MathsUtil.getBeautifulDate(event.data.enddate));
                });
                timeline.graphColor = 0xffffff;
                timeline.setAxis("startdate", "anzahl");
                timeline.x = TIMELINEPADDINGLEFT;
                timeline.y = map.height + TIMELINEPADDINGTOP - 200;
                addChild(timeline);
            });
        }
        private function loadVenues ():void
        {
            this.venues = new Dictionary();
            var st:Statement = con.createStatement();
            var token:MySqlToken = st.executeQuery("SELECT * FROM venues");
            token.addEventListener(MySqlErrorEvent.SQL_ERROR, onError);
            token.addEventListener(MySqlEvent.RESULT, function(event:MySqlEvent)
            {
                for each(var venue_data:* in event.resultSet.getRows()) {
                    var venue:Venue = new Venue(venue_data, currentDataProvider, map)
                    venues[venue.getId()] = venue;
                    map.putMarker(venue.getLocation(), venue);
                }
            });
        }
        private function connectToDatabase ():void
        {
            con = new Connection("localhost", 3306, "conscape", "qmjKynvKXrTF3qqZ", "conscape");
            con.connect();
        }
        private function growMarker (s:Sprite):void
        {
            s.alpha = 0;
            TweenLite.to(s, 1, {alpha:0.5});
        }
        private function killMarker (s:Sprite):void
        {
            TweenLite.to(s, 0.2, {alpha:0, onComplete:function(s:Sprite){
                map.markerClip.removeMarkerObject(s);
            }, onCompleteParams:[s]})
        }
        private function killAllMarkers():void
        {
            var n:Number = 0;
            for each (var m:Object in markers) {
                TweenLite.killTweensOf(m, true);
                killMarker(m as Sprite);
                n++;
            }
            markers = new Dictionary(true);
        }
        private function visualizeEvents (startdate:String, enddate:String=null):void
        {


        }
        private function autoNextDate(event:TimerEvent):void
        {
            if (dates.next()) {
                var date:String = dates.getString("startdate");
                visualizeEvents(date);
            }
        }
        private function nextDate():void
        {
            if (dates.next()) visualizeEvents(dates.getString("startdate"));
        }
        private function onError (event:MySqlErrorEvent):void
        {
            trace(event.msg);
        }
        private function playbackAttendance ():void
        {
            var s:String = "SELECT DATE_FORMAT(startdate, '%Y-%m-%d') startdate FROM EVENTS GROUP BY YEAR(startdate), MONTH(startdate), DAY(startdate) ORDER BY startdate ASC";
            var st:Statement = con.createStatement();
            var token:MySqlToken = st.executeQuery(s);
            token.addEventListener(MySqlErrorEvent.SQL_ERROR, onError);
            token.addEventListener(MySqlEvent.RESULT, function (event:MySqlEvent) {
                   dates = event.resultSet;
                   dates.first();
                   visualizeEvents(dates.getString("startdate"));
                   myTimer = new Timer(100, 0);
                   myTimer.addEventListener(TimerEvent.TIMER, autoNextDate);
                   myTimer.start();
            });
        }
        private function onResize (event:Event = null):void
        {
            var w:Number = stage.stageWidth;
            var h:Number = stage.stageHeight - TIMELINEHEIGHT;

            // Größe und Position der Karte an die Fenstergröße anpassen
            map.x = map.y = 0;
            map.setSize(w, h);
        }
        private function onMapTap (event:TouchEvent):void
        {
            if (event.target is TweenMap) tooltip.visible = false;
        }
        private function onMarkerTap (event:MarkerEvent):void
        {
            if (event.marker is Venue) {
                var pt:Point;
                var venue:Venue = event.marker as Venue;
                map.removeMarker("bla");
                // Tooltip mit dem Namen des Markers anzeigen
                pt = map.locationPoint(event.location);
                tooltip.gfx.venue_name.text = venue.getData("name");
                tooltip.gfx.address.text = venue.getData("street") ? venue.getData("street") : "";
                tooltip.gfx.artists.text = venue.getEventData("numberEvents") && venue.getEventData("totalAttendance") ? venue.getEventData("numberEvents") +" Events, " + venue.getEventData("totalAttendance") + " Besucher" : "";
                
                var newColorTransform:ColorTransform = tooltip.gfx.venueIcon.transform.colorTransform;
                newColorTransform.color = venue.getEventData("prominentGenre").colour;
                tooltip.gfx.venueIcon.transform.colorTransform = newColorTransform;
                
                tooltip.visible = true;
                tooltip.name = "bla";
                tooltip.gfx.y = -150 - venue.height / 2;
                
                map.putMarker(map.pointLocation(pt), tooltip);
                map.zoomTo(14, event.location, null, 0.5);
            }
        }
        private function onCenterZoom (event:GestureEvent):void
        {
            map.setZoom(currentScale);
            currentScale += event.value;
            zooming = true;
            zoomPoint = new Point(event.stageX, event.stageY);
            map.addEventListener(TouchEvent.TOUCH_UP, onStopZoom);
            lastScaleValue = event.value;
        }
        private function onLocationZoom (event:GestureEvent):void
        {
            var location:Point = new Point(event.stageX, event.stageY);
            zooming = true;
            zoomPoint = new Point(event.stageX, event.stageY);
            currentScale += event.value;
            map.zoomByAboutDirty(event.value, location, 0);
            lastScaleValue = event.value;
            map.addEventListener(TouchEvent.TOUCH_UP, onStopZoom);
        }
        private function onMapMove (event:TouchEvent):void
        {
            if (Tracker.getInstance().tactualObjectCount == 1) {
                // todo: Nur bewegen wenn ein einziger Finger drauf ist
                var point:Point = map.locationPoint(map.getCenter());
                var newPoint:Point = new Point(point.x - event.dx, point.y - event.dy);
                var newLatLon:Location = map.pointLocation(newPoint);
                map.setCenter(newLatLon);
            }
        }
        private function onStopZoom(event:TouchEvent):void
        {
            if (zooming) {
                if (lastScaleValue > 0) {
                    var z:Number = Math.ceil(map.grid.zoomLevel);
                    var d:Number = z - map.grid.zoomLevel;
                    //TweenLite.to(map.grid, 0.1, { zoomLevel: z});
                    map.zoomByAbout(d, zoomPoint);
                } else {
                    z = Math.floor(map.grid.zoomLevel);
                    d = map.grid.zoomLevel - z;
                    // TweenLite.to(map.grid, 0.1, { zoomLevel: z});
                    map.zoomByAbout(-d, zoomPoint);
                }
                trace(d);
                currentScale = z;
                zooming = false;
                map.removeEventListener(TouchEvent.TOUCH_UP, onStopZoom);
            }
        }
        private function onKey(event:KeyboardEvent) {
            switch(event.keyCode) {
                case 32:
                    if (black) {
                        TweenLite.to(fader, 1, {alpha: 0});   
                        black = false;
                    } else {
                        TweenLite.to(fader, 1, {alpha: 1});
                        black = true;
                    }
                    break;
            }
        }
    }
}