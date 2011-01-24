package 
{
    import flash.display.Sprite;
    import flash.events.Event;
    
    import com.maclema.mysql.Statement;
    import com.maclema.mysql.Connection;
    import com.maclema.mysql.ResultSet;
    import com.maclema.mysql.MySqlToken;
    import com.maclema.mysql.events.MySqlEvent;
    import com.maclema.mysql.events.MySqlErrorEvent;
    
    public class MySQLTest extends Sprite
    {
        private var con:Connection;
        
        public function MySQLTest() 
        {
            con = new Connection("localhost", 3306, "conscape", "qmjKynvKXrTF3qqZ", "conscape");
            con.addEventListener(Event.CONNECT, handleConnected);
            con.connect();
        }
        private function handleConnected(e:Event):void
        {
            var st:Statement = con.createStatement(); 
            var token:MySqlToken = st.executeQuery("SELECT COUNT(DISTINCT(id)) AS anzahl,lastfm_venue_id FROM events GROUP BY lastfm_venue_id");
            token.addEventListener(MySqlErrorEvent.SQL_ERROR, onError);
            token.addEventListener(MySqlEvent.RESULT, onSuccess);
        }
        private function onSuccess(event:MySqlEvent):void 
        { 
            var rs:ResultSet = event.resultSet;
            while (rs.next())
            {
                trace(rs.getInt("id"));
            }
        }
        private function onError (event:MySqlErrorEvent):void
        {
            trace(event.msg);
        }
    }
}