package conscape.components
{
    import flash.utils.Dictionary;
    import flash.events.EventDispatcher;
    
    import conscape.events.*;
    import conscape.util.MathsUtil;
    
    import com.maclema.mysql.Statement;
    import com.maclema.mysql.Connection;
    import com.maclema.mysql.ResultSet;
    import com.maclema.mysql.MySqlToken;
    import com.maclema.mysql.events.MySqlEvent;
    import com.maclema.mysql.events.MySqlErrorEvent;
    
    public class CurrentDataProvider extends EventDispatcher
    {
        private var venue_event_data:Dictionary;
        private var maxAttendance:Number = 0;
        private var maxNumberEvents:Number = 0;
        private var timeline:Timeline;
        
        private var con:Connection;
        
        public function CurrentDataProvider(_timeline:Timeline, _con:Connection)
        {
            this.venue_event_data = new Dictionary();
            this.timeline = _timeline;
            this.con = _con;
            timeline.addEventListener(TimelineEvent.RANGECHANGE, dateChangeCallback);
        }
        public function getEventDataForVenue(venue_id:String):Object
        {
            return this.venue_event_data[venue_id];
        }
        public function getMaxAttendance():Number
        {
            return this.maxAttendance;
        }
        public function getMaxNumberEvents():Number
        {
            return this.maxNumberEvents;
        }
        private function dateChangeCallback(event:TimelineEvent):void
        {
            var startdate:String = MathsUtil.convertASDateToMySQLTimestamp(event.data.startdate);
            var enddate:String = MathsUtil.convertASDateToMySQLTimestamp(event.data.enddate);
            if (enddate) {
                var query:String = [
                    "SELECT venues.name, venues.lastfm_id, venues.geo_lat, venues.geo_long, events.attendance, events.title, events.startdate, events.anzahl, events.total_attendance",
                    "FROM venues",
                    "INNER JOIN (SELECT lastfm_venue_id, attendance, title, startdate, COUNT(*) AS anzahl, SUM(attendance) AS total_attendance FROM events",
                    "WHERE startdate >= '" + startdate + "%' AND startdate <= '" + enddate + "%' GROUP BY lastfm_venue_id)",
                    "events ON events.lastfm_venue_id = venues.lastfm_id GROUP BY events.lastfm_venue_id ORDER BY events.anzahl DESC"
                    ].join(" ");   
            } else {
                query = [
                    "SELECT venues.name, venues.lastfm_id, venues.geo_lat, venues.geo_long, events.attendance, events.title, events.startdate, events.anzahl",
                    "FROM venues",
                    "INNER JOIN (SELECT lastfm_venue_id, attendance, title, startdate, COUNT(*) AS anzahl FROM events",
                    "WHERE startdate LIKE '" + startdate + "%' GROUP BY lastfm_venue_id)",
                    "events ON events.lastfm_venue_id = venues.lastfm_id GROUP BY events.lastfm_venue_id ORDER BY events.anzahl DESC"
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
                venue_event_data = new Dictionary();
                maxAttendance = 0;
                maxNumberEvents = 0;
                for each(var item:* in event.resultSet.getRows()) {
                    venue_event_data[item["lastfm_id"]] = item;
                    if (item["anzahl"] > maxNumberEvents) maxNumberEvents = item["anzahl"];
                    if (item["total_attendance"] > maxAttendance) maxAttendance = item["total_attendance"];
                }
                dispatchEvent(new CurrentDataProviderEvent(CurrentDataProviderEvent.CHANGE));
            });
        }
    }
}