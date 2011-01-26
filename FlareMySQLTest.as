package 
{
    import com.maclema.mysql.Statement;
    import com.maclema.mysql.Connection;
    import com.maclema.mysql.ResultSet;
    import com.maclema.mysql.MySqlToken;
    import com.maclema.mysql.events.MySqlEvent;
    import com.maclema.mysql.events.MySqlErrorEvent;
    
    import conscape.components.*;
    
    import flare.data.DataSet;
    import flare.data.DataSource;
    import flare.scale.ScaleType;
    import flare.util.Displays;
    import flare.vis.Visualization;
    import flare.vis.controls.PanZoomControl;
    import flare.vis.data.Data;
    import flare.vis.data.NodeSprite;
    import flare.vis.operator.encoder.ColorEncoder;
    import flare.vis.operator.encoder.ShapeEncoder;
    import flare.vis.operator.layout.AxisLayout;
 
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Rectangle;
    import flash.net.URLLoader;
    
    import id.core.Application;
    import gl.events.TouchEvent;
    import gl.events.GestureEvent;
 
    public class FlareMySQLTest extends Application
    {
        private var vis:Visualization;
        private var con:Connection;
        private var timeline:Timeline;
 
        public function FlareMySQLTest()
        {
            this.licenseKey = "18AF7FE030741A38BE7FFBFDAC9590A4E1B66841B6";
            this.settingsPath = "application.xml";
			super();
            loadData();
            addEventListener(GestureEvent.GESTURE_SCALE, onPinch);
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
            var token:MySqlToken = st.executeQuery("SELECT COUNT(startdate) AS anzahl, startdate FROM events WHERE YEAR(startdate) > 0 GROUP BY YEAR(startdate), MONTH(startdate), DAY(startdate)");
            token.addEventListener(MySqlErrorEvent.SQL_ERROR, onError);
            token.addEventListener(MySqlEvent.RESULT, onSuccess);
        }
        private function onSuccess(event:MySqlEvent):void 
        { 
            var rs:ResultSet = event.resultSet;
            var ds:Array = rs.getRows();
            //visualize(Data.fromArray(ds));
            
            timeline = new Timeline(ds);
            timeline.setAxis("startdate", "anzahl");
            addChild(timeline);
            timeline.x = 50;
            timeline.y = 300;
            
        }
        private function onError (event:MySqlErrorEvent):void
        {
            trace(event.msg);
        }
        private function visualize(data:Data):void
        {
            data.createEdges("data.startdate");
            vis = new Visualization(data);
            vis.bounds = new Rectangle(0, 0, 700, 200);
            vis.x = 100;
            vis.y = 50;
            
			var pzc:PanZoomControl = new PanZoomControl();
			vis.controls.add(pzc);
			
            addChild(vis);
            vis.addEventListener(TouchEvent.TOUCH_UP, function (event:TouchEvent) {
                if (event.target is NodeSprite) {
                    trace(event.target.data.startdate);
                    Displays.zoomBy(event.target, 10);                    
                }
            });
 
            vis.operators.add(new AxisLayout("data.startdate", "data.anzahl"));
            vis.data.nodes.setProperties({fillColor:0, lineWidth:2, shape:null});
            vis.update();
            vis.axes.xAxis.labelFormat = "dd/MM/yyyy";
        }
        private function onPinch (event:GestureEvent) 
        {
            /* 
            vis.bounds.width += event.value * 1000;
            vis.bounds.x -= event.value * 500;
            vis.update();
            */
            timeline.setWidth(timeline.getWidth() + event.value * 100);
        }
    }
}