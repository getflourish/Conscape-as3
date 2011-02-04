package conscape.components
{
    import conscape.util.MathsUtil;
    import conscape.view.ScrollView;
    
    import flash.display.Sprite;
    import flash.display.Graphics;
    import flash.geom.Rectangle;
    
    import gl.events.TouchEvent;
    import gl.events.GestureEvent;
    
    import id.core.TouchSprite;
    
    public class Timeline extends TouchSprite
    {
        private var bounds:Rectangle;
        private var data:Object;
        private var fields:Array;
        private var graph:Sprite;
        private var maxXValue:Number;
        private var maxYValue:Number;
        private var minXValue:Number;
        private var minYValue:Number;
        private var minDate:Date;
        private var maxDate:Date;
        private var scrollView:ScrollView;
        private var xAxis:String;
        private var yAxis:String;
        
        public function Timeline (data:Array, width:Number=200, height:Number=100):void
        {
            this.data = data;
            this.fields = [];
            this.bounds = new Rectangle(0, 0, width, height);
            init();
        }
        public function init ():void
        {
            this.graph = new Sprite();
            this.addChild(graph);
            
            this.scrollView = new ScrollView(800, 400, graph);
            this.scrollView.x = 100;
            this.scrollView.y = 100;
            this.scrollView.enableScrolling(ScrollView.HORIZONTAL);
            this.scrollView.addEventListener(GestureEvent.GESTURE_SCALE, onPinch);
            this.scrollView.addEventListener(TouchEvent.TOUCH_UP, onTouchUp);
            this.addChild(scrollView);
        }
        public function update ():void
        {               
            var x:Number = 0;
            var y:Number = 0;
            var n:Number = 0;
            
            graph.graphics.clear();
            graph.graphics.lineStyle(1, 0x777777);
            graph.graphics.moveTo(0, 0);
            
            for each (var o:Object in data) {
                var d:Date = MathsUtil.convertMySQLDateToActionscript(String(o[xAxis]));
                x = d.getTime();
                x = MathsUtil.map(x, minDate.getTime(), maxDate.getTime(), 0, bounds.width);
                y = o[yAxis];
                y = MathsUtil.map(y, 0, maxYValue, 0, bounds.height);
                graph.graphics.moveTo(x, bounds.height);
                graph.graphics.lineTo(x, bounds.height - y);
                n++;
            }
        }
        public function setAxis (xAxis:String, yAxis:String):void
        {
            this.xAxis = xAxis;
            this.yAxis = yAxis; 
            parseData();
            update();
        }
        private function parseData ():void
        {
            // Irgendwann mal schauen ob die Daten sortiert sind
            if (xAxis == undefined && yAxis == undefined) parseFields();
            // Grenzwerte für die Interpolation
            
            this.maxYValue = 0;
            for each(var o:Object in data) {
                if (o[yAxis] > this.maxYValue) this.maxYValue = o[yAxis];
            }  
            this.minXValue = Number(data[0][xAxis]);
            this.minYValue = 0;
            
            this.minDate = MathsUtil.convertMySQLDateToActionscript(String(data[0][xAxis]));
            this.maxDate = MathsUtil.convertMySQLDateToActionscript(String(data[data.length-1][xAxis]));
        }
        private function parseFields ():void
        {
            for (var f:String in data[0]) {
                fields.push(f);
            }
            this.xAxis = fields[0];
            this.yAxis = fields[1];
        }
        public function setBounds(b:Rectangle):void 
        {
            this.bounds = b;
        }
        private function onPinch (event:GestureEvent):void 
        {
            this.scrollView.disableScrolling();
            this.bounds.width = bounds.width + event.value * 1000;
            update();
        }
        private function onTouchUp (event:TouchEvent):void
        {
            this.scrollView.enableScrolling(ScrollView.HORIZONTAL);
        }
    }
}