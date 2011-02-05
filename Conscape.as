package {        import com.adobe.serialization.json.*;        import com.maclema.mysql.Statement;    import com.maclema.mysql.Connection;    import com.maclema.mysql.ResultSet;    import com.maclema.mysql.MySqlToken;    import com.maclema.mysql.events.MySqlEvent;    import com.maclema.mysql.events.MySqlErrorEvent;        import com.modestmaps.Map;    import com.modestmaps.TweenMap;    import com.modestmaps.events.MapEvent;    import com.modestmaps.events.MarkerEvent;    import com.modestmaps.geo.Location;    import com.modestmaps.mapproviders.*;    import com.modestmaps.mapproviders.microsoft.*;        import conscape.components.*;    import conscape.events.*;    import conscape.util.MathsUtil;        import flash.display.StageAlign;    import flash.display.StageScaleMode;    import flash.display.Sprite;    import flash.events.Event;    import flash.events.KeyboardEvent;    import flash.events.TimerEvent;    import flash.filters.ColorMatrixFilter;    import flash.geom.Matrix;    import flash.geom.Point;    import flash.text.TextField;    import flash.text.TextFormat;            import flash.net.URLLoader;    import flash.net.URLRequest;    import flash.net.URLVariables;    import flash.utils.Timer;    import flash.utils.Dictionary;        import id.core.Application;    import id.core.TouchSprite;    import id.tracker.Tracker;        import gl.events.TouchEvent;    import gl.events.GestureEvent;        import gs.TweenLite;    public class Conscape extends Application {                        private const PADDING:int = 20;        private var auto:Boolean = false;        private var cachedMarkers:Dictionary;        private var con:Connection;        private var currentScale = 12;        private var dates:ResultSet;        private var lastScaleValue:Number = 0;        private var map:TweenMap;        private var markers:Dictionary;        private var myTimer:Timer;        private var timeline:Timeline;        private var tooltip:Tooltip;        private var zooming:Boolean = false;        private var zoomPoint:Point;        public function Conscape()         {            this.licenseKey = "18AF7FE030741A38BE7FFBFDAC9590A4E1B66841B6";            this.settingsPath = "application.xml";			super();        	// Falls die Fenstergröße verändert wird (später unnötig aber mal gut zu sehen, wie es geht)            stage.scaleMode = StageScaleMode.NO_SCALE;            stage.align = StageAlign.TOP_LEFT;            stage.addEventListener(Event.RESIZE, onResize);	            	               stage.addEventListener(KeyboardEvent.KEY_DOWN, pause);                        this.markers = new Dictionary(true);                        createMap();             connectToDatabase();   	            createTimeline();            // loadVenueMarkers();                          // Black&White              /*            var matrix:Array = new Array();            matrix=matrix.concat([1,1,1,1]);// red    		matrix=matrix.concat([1,1,1,1]);// green    		matrix=matrix.concat([1,1,1,1]);// blue    		matrix=matrix.concat([0,0,0,1,0]);// alpha    		var my_filter:ColorMatrixFilter=new ColorMatrixFilter(matrix);    		map.grid.filters=[my_filter];    		*/    		        }        private function pause (event:KeyboardEvent):void        {            if (auto) {                if (myTimer.running) {                    myTimer.stop();                } else {                    myTimer.start();                }            }        }        private function createMap():void         {			            // Erstellt eine Karte mit Berlin als Zentrum            // 999 night            // 30059            // Simple beige 30285            map = new TweenMap(                stage.stageWidth,                 stage.stageHeight,                 true,            	new CloudmadeProvider(10,18,"c1862c9125834b9fa203084d73eba088", 999),            	new Location(52.522, 13.405),                currentScale);                            map.x = map.y = 0;            addChild(map);                        map.addEventListener(MarkerEvent.MARKER_TAP, onMarkerTap);            map.addEventListener(GestureEvent.GESTURE_SCALE, onLocationZoom);            map.addEventListener(TouchEvent.TOUCH_MOVE, onMapMove);                        map.blobContainerEnabled = true;                        // Tooltip            tooltip = new Tooltip();            addChild(tooltip);                        // Größe der Karte an das Fenster anpassen            onResize();        }        private function createTimeline():void        {            var st:Statement = con.createStatement();             var token:MySqlToken = st.executeQuery("SELECT COUNT(startdate) AS anzahl, DATE_FORMAT(startdate, '%Y-%m-%d') AS startdate FROM events WHERE YEAR(startdate) > 2005 GROUP BY YEAR(startdate), MONTH(startdate), DAY(startdate)");            token.addEventListener(MySqlErrorEvent.SQL_ERROR, onError);            token.addEventListener(MySqlEvent.RESULT, function(event:MySqlEvent)            {                 var rs:ResultSet = event.resultSet;                var ds:Array = rs.getRows();                timeline = new Timeline(ds, stage.stageWidth, 100);                timeline.addEventListener(TimelineEvent.RANGECHANGE, function(event:TimelineEvent) {                    visualizeAttendance(MathsUtil.convertASDateToMySQLTimestamp(event.data.startdate), MathsUtil.convertASDateToMySQLTimestamp(event.data.enddate));                    timeline.setTitle("Konzerte vom " + MathsUtil.getBeautifulDate(event.data.startdate) + "—" + MathsUtil.getBeautifulDate(event.data.enddate));                });                timeline.setAxis("startdate", "anzahl");                timeline.graphColor = 0x000000;                timeline.x = 0;                timeline.y = map.height + 50;                addChild(timeline);            });        }        private function connectToDatabase ():void        {            con = new Connection("localhost", 3306, "conscape", "qmjKynvKXrTF3qqZ", "conscape");            con.addEventListener(Event.CONNECT, handleConnected);            con.connect();        }        private function handleConnected(e:Event):void        {            // putFlags();            // putBubbles();            // playbackAttendance();        }        private function bearMarker (s:Sprite):void        {            s.alpha = 0;            TweenLite.to(s, 1, {alpha:0.5});        }        private function killMarker (s:Sprite):void        {            TweenLite.to(s, 1, {alpha:0, onComplete:function(s:Sprite){                map.markerClip.removeMarkerObject(s);            }, onCompleteParams:[s]})        }        private function killAllMarkers():void        {            var n:Number = 0;            trace("Jetzt sterbt doch endlich mal!");            trace("===============================");            for each (var m:Object in markers) {                TweenLite.killTweensOf(m, true);                killMarker(m as Sprite);                n++;            }            markers = new Dictionary(true);            trace(n);            // map.markerClip.removeAllMarkers();        }        private function putFlags ():void        {            fu.alpha = 0;            var s:String = "SELECT * FROM venues";                        var st:Statement = con.createStatement();             var token:MySqlToken = st.executeQuery(s);            token.addEventListener(MySqlErrorEvent.SQL_ERROR, onError);            token.addEventListener(MySqlEvent.RESULT, function (event:MySqlEvent) {                var venues:ResultSet = event.resultSet;                while (venues.next()) {                    if (venues.getString("geo_lat") && venues.getString("geo_long")) {                        var lat:Number = venues.getNumber("geo_lat");                        var lng:Number = venues.getNumber("geo_long")                        var marker:SampleMarker = new SampleMarker();                        marker.title = venues.getString("name") + ": " + venues.getString("anzahl");                        var location:Location = new Location(lat, lng);                        map.putMarker(location, marker);                    }                }            });            }        private function putBubbles ():void        {            fu.alpha = 0;            var s:String = "SELECT venues.name, venues.lastfm_id, venues.geo_lat, venues.geo_long, events.anzahl";            s += " FROM venues";            s += " INNER JOIN (SELECT lastfm_venue_id, COUNT(*) AS anzahl FROM events GROUP BY lastfm_venue_id)";             s += " events ON events.lastfm_venue_id = venues.lastfm_id ORDER BY events.anzahl DESC";                        var st:Statement = con.createStatement();             var token:MySqlToken = st.executeQuery(s);            token.addEventListener(MySqlErrorEvent.SQL_ERROR, onError);            token.addEventListener(MySqlEvent.RESULT, function (event:MySqlEvent) {                var venues:ResultSet = event.resultSet;                while (venues.next()) {                    if (venues.getString("geo_lat") && venues.getString("geo_long")) {                        var lat:Number = venues.getNumber("geo_lat");                        var lng:Number = venues.getNumber("geo_long")                        var marker:BubbleMarker = new BubbleMarker();                        marker.title = venues.getString("name") + ": " + venues.getString("anzahl");                        var location:Location = new Location(lat, lng);                        var m:Matrix = marker.transform.matrix;                        var c:Point = new Point(marker.x / 2, marker.y / 2);                        var s:Number = venues.getNumber("anzahl") / 10 + 1;                        m.translate(-c.x, -c.y);                        m.scale(s, s);                        m.translate(c.x, c.y);                        marker.transform.matrix = m;                        marker.alpha = 0.5;                        map.putMarker(location, marker);                    }                }            });        }        private function visualizeAttendance (startdate:String, enddate:String=null):void        {            trace("before: " + map.markerClip.getMarkerCount());            var s:String = "SELECT venues.name, venues.lastfm_id, venues.geo_lat, venues.geo_long, events.attendance, events.title, events.startdate, events.anzahl";            s += " FROM venues";            s += " INNER JOIN (SELECT lastfm_venue_id, attendance, title, startdate, COUNT(*) AS anzahl FROM events ";            if (enddate) {                s += "WHERE startdate >= '" + startdate + "%' AND startdate <= '" + enddate + "%' GROUP BY lastfm_venue_id)";            } else {                s += "WHERE startdate LIKE '" + startdate + "%' GROUP BY lastfm_venue_id)";            }            s += " events ON events.lastfm_venue_id = venues.lastfm_id GROUP BY events.lastfm_venue_id ORDER BY events.startdate ASC";                        killAllMarkers();                        trace("after: " + map.markerClip.getMarkerCount());                        var st:Statement = con.createStatement();             var token:MySqlToken = st.executeQuery(s);            token.addEventListener(MySqlErrorEvent.SQL_ERROR, onError);            token.addEventListener(MySqlEvent.RESULT, function (event:MySqlEvent) {                var data:ResultSet = event.resultSet;                                cachedMarkers = new Dictionary(true);                // Cache existing markers                for (var markerName:String in markers) {                    cachedMarkers[markerName] = markers[markerName];                }                                while (data.next()) {                    if (data.getString("geo_lat") && data.getString("geo_long")) {                        var lat:Number = data.getNumber("geo_lat");                        var lng:Number = data.getNumber("geo_long")                        var marker:BubbleMarker = new BubbleMarker();                        marker.title = data.getString("name");                        var location:Location = new Location(lat, lng);                        var m:Matrix = marker.ellipse.transform.matrix;                        var c:Point = new Point(marker.x / 2, marker.y / 2);                        var s:Number = data.getNumber("anzahl") / 100 + 1;                        m.translate(-c.x, -c.y);                        m.scale(s, s);                        m.translate(c.x, c.y);                        marker.ellipse.transform.matrix = m;                        marker.ellipse.alpha = 0.5;                        marker.textLabel.label.text = String(data.getNumber("anzahl"));                        marker.textLabel.cacheAsBitmap = true;                                                trace(markers[marker.title]);                        if (markers[marker.title] == undefined) {                            map.putMarker(location, marker);                            markers[marker.title] = marker;                            bearMarker(marker);                        } else {                            bearMarker(marker);                            delete cachedMarkers[marker.title];                        }                     }                }                for each (var o:Object in cachedMarkers) {                    killMarker(o as Sprite);                }                trace("new: " + map.markerClip.getMarkerCount());            });        }        private function autoNextDate(event:TimerEvent):void        {            if (dates.next()) {                var date:String = dates.getString("startdate");                fu.text = date;                // map.markerClip.removeAllMarkers();                visualizeAttendance(date);            }        }        private function nextDate():void        {            if (dates.next()) visualizeAttendance(dates.getString("startdate"));        }        private function onError (event:MySqlErrorEvent):void        {            trace(event.msg);        }        private function playbackAttendance ():void        {            var s:String = "SELECT DATE_FORMAT(startdate, '%Y-%m-%d') startdate FROM EVENTS GROUP BY YEAR(startdate), MONTH(startdate), DAY(startdate) ORDER BY startdate ASC";             var st:Statement = con.createStatement();             var token:MySqlToken = st.executeQuery(s);            token.addEventListener(MySqlErrorEvent.SQL_ERROR, onError);            token.addEventListener(MySqlEvent.RESULT, function (event:MySqlEvent) {                   dates = event.resultSet;                   dates.first();                   visualizeAttendance(dates.getString("startdate"));                    myTimer = new Timer(100, 0);                   myTimer.addEventListener(TimerEvent.TIMER, autoNextDate);                   myTimer.start();            });        }        private function loadVenueMarkers ()        {               var loader:URLLoader = new URLLoader();            loader.addEventListener(Event.COMPLETE, placeVenueMarkers);            var request:URLRequest = new URLRequest("venues_lastfm.json");            try {                loader.load(request);            } catch (error:Error) {                trace("File not found!")            }        }           private function placeVenueMarkers (event:Event):void         {            var loader:URLLoader = URLLoader(event.target);            var data:Object = JSON.decode(loader.data);                        // Einen Marker für jede Venue auf der Karte platzieren            for each (var venue:Object in data.venues) {                if (venue.geo_lat && venue.geo_long) {                    var marker:SampleMarker = new SampleMarker();                    marker.title = venue.name;                    var location:Location = new Location(venue.geo_lat, venue.geo_long);                    map.putMarker(location, marker);                }            }        }        private function onResize (event:Event = null):void         {            var w:Number = stage.stageWidth;            var h:Number = stage.stageHeight - 10 * PADDING;	    	            // Größe und Position der Karte an die Fenstergröße anpassen            map.setSize(w, h);        }        private function onMarkerTap (event:MarkerEvent):void         {            trace(event.marker);            if (event.marker is SampleMarker) {                var marker:SampleMarker = event.marker as SampleMarker;                map.removeMarker("bla");                   // Tooltip mit dem Namen des Markers anzeigen                var pt:Point = map.locationPoint(event.location);                tooltip.label = marker.title;                tooltip.visible = true;                tooltip.name = "bla";                map.putMarker(map.pointLocation(pt), tooltip);                   map.zoomTo(14, event.location, null, 0.5);            } else if (event.marker is BubbleMarker) {                trace("tap");                var b:BubbleMarker = event.marker as BubbleMarker;                map.removeMarker("bla");                   // Tooltip mit dem Namen des Markers anzeigen                pt = map.locationPoint(event.location);                tooltip.label = b.title;                tooltip.visible = true;                tooltip.name = "bla";                map.putMarker(map.pointLocation(pt), tooltip);                   map.zoomTo(14, event.location, null, 0.5);             }        }        private function onCenterZoom (event:GestureEvent):void        {            map.setZoom(currentScale);            currentScale += event.value;            zooming = true;            zoomPoint = new Point(event.stageX, event.stageY);            map.addEventListener(TouchEvent.TOUCH_UP, onStopZoom);            lastScaleValue = event.value;        }        private function onLocationZoom (event:GestureEvent):void        {            var location:Point = new Point(event.stageX, event.stageY);            zooming = true;            zoomPoint = new Point(event.stageX, event.stageY);            currentScale += event.value;            map.zoomByAboutDirty(event.value, location, 0);            lastScaleValue = event.value;            map.addEventListener(TouchEvent.TOUCH_UP, onStopZoom);        }        private function onMapMove (event:TouchEvent):void        {            if (Tracker.getInstance().tactualObjectCount == 1) {                // todo: Nur bewegen wenn ein einziger Finger drauf ist                var point:Point = map.locationPoint(map.getCenter());                var newPoint:Point = new Point(point.x - event.dx, point.y - event.dy);                var newLatLon:Location = map.pointLocation(newPoint);                map.setCenter(newLatLon);                            }        }        private function onStopZoom(event:TouchEvent):void        {            if (zooming) {                if (lastScaleValue > 0) {                    var z:Number = Math.ceil(map.grid.zoomLevel);                    var d:Number = z - map.grid.zoomLevel;                    //TweenLite.to(map.grid, 0.1, { zoomLevel: z});                    map.zoomByAbout(d, zoomPoint);                } else {                    z = Math.floor(map.grid.zoomLevel);                    d = map.grid.zoomLevel - z;                    // TweenLite.to(map.grid, 0.1, { zoomLevel: z});                    map.zoomByAbout(-d, zoomPoint);                }                trace(d);                currentScale = z;                zooming = false;                map.removeEventListener(TouchEvent.TOUCH_UP, onStopZoom);            }        }    }}