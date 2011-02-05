package conscape.components
{
    import conscape.events.*;
    import conscape.util.MathsUtil;
    import conscape.view.ScrollView;
    
    import flash.display.Sprite;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import flash.text.Font;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.Dictionary;
    
    import gl.events.TouchEvent;
    import gl.events.GestureEvent;
    
    import id.core.TouchSprite;
    
    public class Timeline extends TouchSprite
    {
        private var bounds:Rectangle;
        private var boundsRectangle:Shape;
        private var data:Object;
        private var dateLabelHeight:Number = 20;
        private var dateLabelWidth:Number = 50;
        private var dateLabelPaddingY:Number = 5;
        private var dateAxis:Sprite;
        private var dictionary:Dictionary;
        private var fields:Array;
        private var graph:Sprite;
        private var graphBounds:Rectangle;
        private var background:Sprite;
        private var initWidth;
        private var initHeight;
        private var mapping:Array;
        private var maxXValue:Number;
        private var maxYValue:Number;
        private var minXValue:Number;
        private var minYValue:Number;
        private var minDate:Date;
        private var maxDate:Date;
        private var padding:Number = 15;
        private var pinchCenterX:Number = 0;
        private var timeScale:Number = 1;
        private var title:TextField;
        private var titleFormat:TextFormat;
        private var scrollView:ScrollView;
        private var xAxis:String;
        private var yAxis:String;
        
        public var graphColor:uint = 0x000000;
        
        public function Timeline (data:Array, width:Number=200, height:Number=100, padding:Number=15):void
        {
            this.data = data;
            this.fields = [];
            this.padding = padding;
            this.bounds = new Rectangle(padding, padding, width-2*padding, height-2*padding);
            this.graphBounds = new Rectangle(padding, padding, width-2*padding, height - dateLabelHeight - 2*padding);
            this.initWidth = width;
            this.initHeight = height;
            Font.registerFont(LabelFont);
            init();
        }
        public function init ():void
        {
            // Das Diagramm, das aus Graphen und Beschriftung besteht
            this.graph = new Sprite();
            this.addChild(graph);
        	
        	// Scrollview, worin sich das Diagramm befindet
            this.scrollView = new ScrollView(bounds.width, bounds.height, graph);
            this.scrollView.x = 0;
            this.scrollView.y = 0;
            this.scrollView.enableScrolling(ScrollView.HORIZONTAL);
            this.scrollView.addEventListener(GestureEvent.GESTURE_SCALE, onPinch);
            this.scrollView.addEventListener(TouchEvent.TOUCH_UP, onTouchUp);
            this.addChild(scrollView);
            
            // Hintergrund
            background = new Sprite();
			boundsRectangle = new Shape();
			boundsRectangle.graphics.beginFill(0x0000ff, 0.1);
			boundsRectangle.graphics.drawRect(0, 0, bounds.width, bounds.height);
			boundsRectangle.graphics.endFill();
			background.addChild(boundsRectangle);
			addChild(background);
			
			// Titel des Diagrams (wird vom Hauptprogramm gesetzt)
			
			titleFormat = new TextFormat();
            titleFormat.color = 0x000000;
            titleFormat.size = 18;
            titleFormat.font = "Consolas";
            
			this.title = new TextField();
			this.addChild(title);
            this.title.width = graphBounds.width;
            this.title.x = padding;
            this.title.y = -padding - Number(titleFormat.size);
            this.title.selectable = false;
            this.title.text = "BLA";
            
            this.title.setTextFormat(titleFormat);
			
			// Die Achsenbeschriftung der Zeitachse
			this.dateAxis = new Sprite();
			this.dateAxis.x = 0;
			this.dateAxis.y = graphBounds.height;
			this.scrollView.content.addChild(dateAxis);
		}
        public function initMapping ():void
        {            
            this.parseData();
            this.mapping = [];
            this.dictionary = new Dictionary(true);
            var x:Number = 0;
            var y:Number = 0;
            for each (var o:Object in data) {
                var d:Date = MathsUtil.convertMySQLDateToActionscript(String(o[xAxis]));
                x = d.getTime();
                x = MathsUtil.map(x, minDate.getTime(), maxDate.getTime(), 0, graphBounds.width);
                y = o[yAxis];
                y = MathsUtil.map(y, 0, maxYValue, 0, graphBounds.height);
                this.mapping.push({"date":d, "x":x, "y":y});
                this.dictionary[d] = x;
            }
        }
        private function drawBounds(width:Number=0, height:Number = 0):void
        {
            boundsRectangle.graphics.clear();
			boundsRectangle.graphics.beginFill(0xff0000, 0.1);
			boundsRectangle.graphics.drawRect(0, 0, width, height);
			boundsRectangle.graphics.endFill();
        }
        private function fireRangeChange():void
        {
            var b:Rectangle = scrollView.getBoundingRectangle();
            var deltaX:Number = Math.abs(scrollView.content.x);
            var start:Date = getDateForX(deltaX);
            var end:Date = getDateForX(deltaX + b.width);
            var data:Object = {"startdate":start, "enddate":end};
            this.dispatchEvent(new TimelineEvent(TimelineEvent.RANGECHANGE, data));
        }
        public function getDateForX (x:Number):Date
        {
            var x:Number = x;
            var b:Rectangle = scrollView.getBoundingRectangle();
            x = MathsUtil.map(x, 0, graph.width, minDate.getTime(), maxDate.getTime());
            var d:Date = new Date(x);
            return d;
        }
        public function getXForDate (date:Date):Number
        {
            var d:Date = date;
            var b:Rectangle = scrollView.getBoundingRectangle();
            x = MathsUtil.map(x, 0, graph.width, minDate.getTime(), maxDate.getTime());
            return x;
        }
        private function onPinch (event:GestureEvent):void 
        {
            this.scrollView.disableScrolling();
            this.timeScale += event.value * 10;

            if (pinchCenterX == 0) pinchCenterX = event.localX, event.localY;
            var ratio:Number = pinchCenterX / scrollView.getBoundingRectangle().width;
            var oldW:Number = graph.width;
            update();
            fireRangeChange();
            updateAxis();
            var newW:Number = graph.width;
            scrollView.content.x += (oldW - newW) * ratio;
        }
        private function onTouchUp (event:TouchEvent):void
        {
            pinchCenterX = 0;
            this.scrollView.enableScrolling(ScrollView.HORIZONTAL);
            fireRangeChange();
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
        public function setAxis (xAxis:String, yAxis:String):void
        {
            this.xAxis = xAxis;
            this.yAxis = yAxis; 
            parseData();
            initMapping();
            update();
            updateAxis();
        }
        public function setBounds(b:Rectangle):void 
        {
            this.bounds = b;
        }
        public function setTitle(title:String):void
        {
            this.title.text = title;
            this.title.setTextFormat(titleFormat);
        }
        public function update ():void
        {               
            var x:Number = 0;
            var y:Number = 0;
            var n:Number = 0;
            
            graph.graphics.clear();
            graph.graphics.lineStyle(1, graphColor);
            graph.graphics.moveTo(0, 0);

            var bottom:Number = bounds.height - dateLabelHeight;
            for each (var o:Object in mapping) {
                x = o.x * timeScale;
                y = o.y;
                var deltaX:Number = 100;
                graph.graphics.moveTo(x, bottom);
                graph.graphics.lineTo(x, bottom - y);
            }
            var deltaX:Number = Math.abs(scrollView.content.x);
            var d:Date = getDateForX(deltaX);
            updateAxis();
        }
        private function updateAxis():void
        {
            while (dateAxis.numChildren) {
            	dateAxis.removeChildAt(0);
            }
            var numDates:Number = maxDate.fullYear - minDate.fullYear;
            var spacing:Number = scrollView.content.width / numDates;
            var x:Number = 0;
            for (var i:Number = 0; i < numDates; i++) {
                var dateLabel:TextField = new TextField();  
                dateAxis.addChild(dateLabel);
                dateLabel.width = dateLabelWidth;
                dateLabel.x = x;
                dateLabel.y = dateLabelPaddingY;
                dateLabel.text = "’" + String(getDateForX(x).fullYear).slice(2);
                dateLabel.selectable = false;
                
                var format:TextFormat = new TextFormat();
                format.color = graphColor;
                format.size = 14;
                format.font = "Consolas";
                dateLabel.setTextFormat(format);
                
                x += spacing;
            }
        }
    }
}