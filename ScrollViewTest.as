package 
{
    import com.maclema.mysql.Statement;
    import com.maclema.mysql.Connection;
    import com.maclema.mysql.ResultSet;
    import com.maclema.mysql.MySqlToken;
    import com.maclema.mysql.events.MySqlEvent;
    import com.maclema.mysql.events.MySqlErrorEvent;
    
    import conscape.components.*;
    import conscape.events.*;
    import conscape.view.ScrollView;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Rectangle;
    import flash.net.URLLoader;
    
    import id.core.Application;
    import id.core.TouchSprite;
    import gl.events.TouchEvent;
    import gl.events.GestureEvent;
 
    public class ScrollViewTest extends Application
    {
        private var zooming:Boolean;
        private var initialX:Number;
        private var initialWidth:Number;
        private var con:Connection;
        private var timeline:Timeline;
 
        public function ScrollViewTest()
        {
            this.licenseKey = "18AF7FE030741A38BE7FFBFDAC9590A4E1B66841B6";
            this.settingsPath = "application.xml";
			super();
            
            loadData();
        }
 
        private function loadData():void
        {
            con = new Connection("localhost", 3306, "conscape", "qmjKynvKXrTF3qqZ", "conscape");
            con.addEventListener(Event.CONNECT, handleConnected);
            con.connect();
        }
        private function handleConnected(e:Event):void
        {
            var st:Statement = con.createStatement(); 
            var token:MySqlToken = st.executeQuery("SELECT COUNT(startdate) AS anzahl, DATE_FORMAT(startdate, '%Y-%m-%d') AS startdate FROM events WHERE YEAR(startdate) > 0 GROUP BY YEAR(startdate), MONTH(startdate), DAY(startdate)");
            token.addEventListener(MySqlErrorEvent.SQL_ERROR, onError);
            token.addEventListener(MySqlEvent.RESULT, onSuccess);
        }
        private function onSuccess(event:MySqlEvent):void 
        { 
            var rs:ResultSet = event.resultSet;
            var ds:Array = rs.getRows();
            trace(ds);
            timeline = new Timeline(ds, 700, 300);
            timeline.setAxis("startdate", "anzahl");
            timeline.update();
            timeline.x = 0;
            timeline.y = 0;
            addChild(timeline);
            timeline.addEventListener(TimelineEvent.RANGECHANGE, function(event:TimelineEvent) {
                trace("range changed");
            });
        }
        private function onError (event:MySqlErrorEvent):void
        {
            trace(event.msg);
        }
    }
}