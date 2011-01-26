package 
{
    import com.maclema.mysql.Statement;
    import com.maclema.mysql.Connection;
    import com.maclema.mysql.ResultSet;
    import com.maclema.mysql.MySqlToken;
    import com.maclema.mysql.events.MySqlEvent;
    import com.maclema.mysql.events.MySqlErrorEvent;
    
    import conscape.components.*;
    import conscape.view.ScrollView;
    
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
    import id.core.TouchSprite;
    import gl.events.TouchEvent;
    import gl.events.GestureEvent;
 
    public class FlareMySQLTest extends Application
    {
        private var zooming:Boolean;
        private var initialX:Number;
        private var initialWidth:Number;
        private var flare:Boolean = false;
        private var vis:Visualization;
        private var con:Connection;
        private var timeline:Timeline;
        private var scrollview:ScrollView;
 
        public function FlareMySQLTest()
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
            
            if (flare) {
                visualize(Data.fromArray(ds));
            } else {
                timeline = new Timeline(ds);
                timeline.setAxis("startdate", "anzahl");
                timeline.update();
                timeline.x = 0;
                timeline.y = 0;

    			this.scrollview = new ScrollView(800, 400, timeline);
                this.scrollview.x = 100;
                this.scrollview.y = 100;
                this.scrollview.enableScrolling(ScrollView.HORIZONTAL);
                this.scrollview.addEventListener(GestureEvent.GESTURE_SCALE, onPinch);
                this.scrollview.addEventListener(TouchEvent.TOUCH_UP, onTouchUp);
                this.addChild(scrollview);
            }
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
            vis.x = 0;
            vis.y = 0;
            
			var pzc:PanZoomControl = new PanZoomControl();
			vis.controls.add(pzc);
			
			this.scrollview = new ScrollView(800, 400, vis);
            this.scrollview.x = 100;
            this.scrollview.y = 100;
            this.scrollview.enableScrolling(ScrollView.HORIZONTAL);
            this.scrollview.addEventListener(GestureEvent.GESTURE_SCALE, onPinch);
            this.scrollview.addEventListener(TouchEvent.TOUCH_UP, onTouchUp);
            this.addChild(scrollview);

            vis.addEventListener(TouchEvent.TOUCH_UP, function (event:TouchEvent) {
                if (event.target is NodeSprite) {
                    Displays.zoomBy(event.target, 10);                    
                }
            });
 
            vis.operators.add(new AxisLayout("data.startdate", "data.anzahl"));
            vis.data.nodes.setProperties({fillColor:0, lineWidth:2, shape:null});
            vis.update();
            vis.axes.xAxis.labelFormat = "dd/MM/yyyy";
        }
        private function onPinch (event:GestureEvent):void 
        {
            if (flare) {
                if (!zooming) {
                    initialWidth = vis.bounds.width;
                    initialX = vis.x;
                }
                zooming = true;
                vis.width += event.value * 1000;
            } else {
                this.scrollview.disableScrolling();
                timeline.setWidth(timeline.getWidth() + event.value * 1000);
            }
        }
        private function onTouchUp (event:TouchEvent):void
        {
            if (flare) {
                if (zooming) {
                    var w:Number = vis.width;
                    vis.width = initialWidth;
                    vis.bounds.width = w;
                    vis.update();
                    zooming = false;
                    scrollview.update();
                }
            } else {
                this.scrollview.enableScrolling(ScrollView.HORIZONTAL);
                //scrollview.update();
            }
        }
    }
}