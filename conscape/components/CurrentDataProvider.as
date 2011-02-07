package conscape.components
{
    import flash.utils.Dictionary;
    import flash.events.EventDispatcher;
    import flash.events.ErrorEvent;
    
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
        private var totalGenres:Object;
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
        public function getTotalGenres():Object
        {
            return this.totalGenres;
        }
        private function dateChangeCallback(event:TimelineEvent):void
        {
            var startdate:String = MathsUtil.convertASDateToMySQLTimestamp(event.data.startdate);
            var enddate:String = MathsUtil.convertASDateToMySQLTimestamp(event.data.enddate);
            if (enddate) {
                var query:String = [
                    "SELECT lastfm_venue_id, COUNT(*) as number_events, SUM(attendance) as total_attendance, GROUP_CONCAT(genres SEPARATOR ',') as genre_list",
                    "FROM events",
                    "WHERE startdate BETWEEN '"+startdate+"' AND '"+enddate+"'",
                    "GROUP BY lastfm_venue_id"
                    ].join(" ");   
            } else {
                query = [
                    "SELECT lastfm_venue_id, COUNT(*) as number_events, SUM(attendance) as total_attendance, GROUP_CONCAT(genres SEPARATOR ',') as genre_list",
                    "FROM events",
                    "WHERE startdate Like '"+startdate+"'",
                    "GROUP BY lastfm_venue_id"
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
                totalGenres = Genre.getGenreObject();
                for each(var item:* in event.resultSet.getRows()) {
                    var genres:Object = Genre.getGenreObject();
                    if (item["genre_list"]) {
                        for each(var genreName:String in String(item["genre_list"]).split(",")) {
                                genres[genreName]["count"] += 1;
                                totalGenres[genreName]["count"] += 1;   
                        }
                    }
                    venue_event_data[item["lastfm_venue_id"]] = {
                        "numberEvents": item["number_events"],
                        "totalAttendance": item["total_attendance"],
                        "genres": genres
                    };
                    if (item["number_events"] > maxNumberEvents) maxNumberEvents = item["number_events"];
                    if (item["total_attendance"] > maxAttendance) maxAttendance = item["total_attendance"];
                }
                dispatchEvent(new CurrentDataProviderEvent(CurrentDataProviderEvent.CHANGE, {
                    "maxNumberEvents": maxNumberEvents,
                    "maxAttendance": maxAttendance,
                    "totalGenres": totalGenres
                }));
            });
            
        }
    }
}