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
            parseData();
            update();
        }
        public function update ():void
        {               
            var x:Number = 0;
            var y:Number = 0;
            var n:Number = 0;
            
            graph.graphics.clear();
            graph.graphics.lineStyle(1, 0x000000);
            graph.graphics.moveTo(0, 0);
            for each (var o:Object in data) {
                // todo: Irgendwie herausfinden wie die Felder heißen
                x = o[xAxis];
                x = MathsUtil.map(n, 0, 100, 0, bounds.width);
                y = o[yAxis];
                y = MathsUtil.map(y, minYValue, maxYValue, 0, bounds.height);
                graph.graphics.lineTo(x, -y);
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
             parseFields();
            // Grenzwerte für die Interpolation
            this.minXValue = Number(data[0][xAxis]);
            this.maxXValue = Number(data[data.length-1][xAxis]);
            this.minYValue = Number(data[0][yAxis]);
            this.maxYValue = Number(data[data.length-1][yAxis]);
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
        public function getWidth ():Number 
        {
            return bounds.width;
        }
        public function setWidth(w:Number):void {
            this.bounds.width = w;
            update();
        }
    }
}