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
        private var numberOfDays:Number = 0;
        private var totalGenres:Object;
        private var totalGenreCount:Number;
        private var timeline:Timeline;
        private var selectedGenres:Dictionary;
        
        private var con:Connection;
        
        public function CurrentDataProvider(_timeline:Timeline, _con:Connection)
        {
            this.venue_event_data = new Dictionary();
            this.timeline = _timeline;
            this.con = _con;
            this.selectedGenres = new Dictionary();
            for each(var gid:String in Genre.ORDER) {
                this.selectedGenres[gid] = true;
		    }
            timeline.addEventListener(TimelineEvent.RANGECHANGE, dateChangeCallback);
        }
        public function getConnection():Connection
        {
            return this.con;
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
        public function getTotalGenreCount():Number
        {
            return this.totalGenreCount;
        }
        public function selectGenre(id:String):void
        {
            this.selectedGenres[id] = true;
            this.selectedGenresChanged();
        }
        public function unselectGenre(id:String):void
        {
            this.selectedGenres[id] = false;
            this.selectedGenresChanged();
        }
        public function toggleSelectionOfGenre(id:String):Boolean
        {
            this.selectedGenres[id] = !this.selectedGenres[id];
            this.selectedGenresChanged();
            return this.selectedGenres[id];
        }
        public function isSelectedGenre(id:String):Boolean
        {
            return this.selectedGenres[id];
        }
        private function selectedGenresChanged():void
        {
            dispatchEvent(new CurrentDataProviderEvent(CurrentDataProviderEvent.CHANGE, {
                "maxNumberEvents": maxNumberEvents,
                "maxAttendance": maxAttendance,
                "totalGenres": totalGenres,
                "totalGenreCount": totalGenreCount,
                "numberOfDays": numberOfDays,
                "selectedGenres": this.selectedGenres
            }));
            dispatchEvent(new CurrentDataProviderEvent(CurrentDataProviderEvent.GENRE_FILTER_CHANGE, this.selectedGenres));
        }
        public function getSelectedGenres():Object
        {
            return this.selectedGenres;
        }
        private function getNewData(_startdate:Date, _enddate:Date, numberOfDays:Number):void
        {
            var startdate:String = MathsUtil.convertASDateToMySQLTimestamp(_startdate);
            var enddate:String = MathsUtil.convertASDateToMySQLTimestamp(_enddate);

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
                totalGenreCount = 0;
                totalGenres = Genre.getGenreObject();
                for each(var item:* in event.resultSet.getRows()) {
                    var genres:Object = Genre.getGenreObject();
                    var prominentGenre = Genre.getGenre("andere");
                    if (item["genre_list"]) {
                        trace("j " + item["number_events"]);
                        for each(var genreName:String in String(item["genre_list"]).split(",")) {
                            genres[genreName]["count"] += 1;
                            totalGenres[genreName]["count"] += 1;
                            totalGenreCount += 1;
                        }
                        for each(var genreItem:Object in genres) {
                            if (genreItem["count"] > prominentGenre["count"]) {
                                prominentGenre = genreItem;
                            }
                        }
                    } else {
                        // TODO: HACK
                        trace("n " + item["number_events"] + " " + item["lastfm_venue_id"]);
                        genres["andere"]["count"] += Math.ceil(item["number_events"]/2);
                        totalGenres["andere"]["count"] += Math.ceil(item["number_events"]/2);
                        totalGenreCount += Math.ceil(item["number_events"]/2);
                    }
                    venue_event_data[item["lastfm_venue_id"]] = {
                        "numberEvents": item["number_events"],
                        "totalAttendance": item["total_attendance"],
                        "genres": genres,
                        "prominentGenre": prominentGenre
                    };
                    if (item["number_events"] > maxNumberEvents) maxNumberEvents = item["number_events"];
                    if (item["total_attendance"] > maxAttendance) maxAttendance = item["total_attendance"];
                }
                dispatchEvent(new CurrentDataProviderEvent(CurrentDataProviderEvent.CHANGE, {
                    "maxNumberEvents": maxNumberEvents,
                    "maxAttendance": maxAttendance,
                    "totalGenres": totalGenres,
                    "totalGenreCount": totalGenreCount,
                    "numberOfDays": numberOfDays,
                    "selectedGenres": this.selectedGenres
                }));
            });
        }
        private function dateChangeCallback(event:TimelineEvent):void
        {
            this.getNewData(event.data.startdate, event.data.enddate, event.data.numberOfDays);
        }
    }
}