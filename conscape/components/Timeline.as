package conscape.components
{
    import conscape.events.*;
    import conscape.util.MathsUtil;
    import conscape.util.Dates;
    import conscape.view.ScrollView;
     
    import flash.geom.*;
    import flash.display.*;
    
    import flash.filters.BitmapFilter;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.DropShadowFilter;
 
    import flash.text.Font;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.Dictionary;
     
    import gl.events.TouchEvent;
    import gl.events.GestureEvent;
     
    import id.core.TouchSprite;
    import id.tracker.Tracker;
     
    import nl.demonsters.debugger.MonsterDebugger;
     
    public class Timeline extends TouchSprite
    {
        private var debugger:MonsterDebugger;
        private var axisFormat:TextFormat;
        private var bounds:Rectangle;
        private var boundsRectangle:Shape;
        private var data:Object;
        private var dateLabelHeight:Number = 20;
        private var dateLabelWidth:Number = 70;
        private var dateLabelPaddingY:Number = 5;
        private var dateAxis:Sprite;
        private var dictionary:Dictionary;
        private var enddate:Date;
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
        private var numberOfDays:Number = 0;
        private var padding:Number = 15;
        private var xPadding:Number = 0;
        private var pinchCenterX:Number = 0;
        private var startdate:Date;
        private var timeScale:Number = 1;
        private var title:TextField;
        public var date1:TextField;
        public var date2:TextField;
        private var titleFormat:TextFormat;
        private var today:Date;
        private var scrollView:ScrollView;
        private var xAxis:String;
        private var yAxis:String;
         
        public var graphColor:uint = 0xffffff;
         
        public function Timeline (data:Array, width:Number=200, height:Number=100, padding:Number=15):void
        {
            debugger = new MonsterDebugger(this);
            
            this.today = new Date(2011,1,8); 
            this.data = data;
            this.fields = [];
            this.padding = padding;
            this.bounds = new Rectangle(xPadding, padding, width, height-2*padding);
            this.graphBounds = new Rectangle(xPadding, padding, width-2*xPadding, height - dateLabelHeight - 2*padding);
            this.initWidth = width;
            this.initHeight = height;
            this.initFormats();
            init();
        }
        public function getStartDate():Date
        {
            return this.startdate;
        }
        public function getEndDate():Date
        {
            return this.enddate;
        }
        public function setData(_data:Array):void
        {
            this.data = _data;
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
            this.scrollView.showsHorizontalScrollIndicator = true;
            this.scrollView.indicatorColor = 0x2A2A2A;
            this.scrollView.addEventListener(GestureEvent.GESTURE_SCALE, onPinch);
            this.scrollView.addEventListener(TouchEvent.TOUCH_UP, onTouchUp);
            this.scrollView.addEventListener(TouchEvent.TOUCH_DOWN, onTouchDown);
            this.scrollView.addEventListener(ScrollEvent.SCROLL, onScroll);
            this.addChild(scrollView);
             
            // Hintergrund
            
            // Dropshadow
            var dropShadow:DropShadowFilter = new DropShadowFilter();
            dropShadow.color = 0x000000;
            dropShadow.blurX = 5;
            dropShadow.blurY = 5;
            dropShadow.angle = 90;
            dropShadow.alpha = 0.5;
            dropShadow.distance = 0;
            dropShadow.quality = BitmapFilterQuality.HIGH;
            
            // Gradient
            var fType:String = GradientType.LINEAR;
            var colors:Array = [ 0xF1F1F1, 0xAAAAAA ];
            var alphas:Array = [ 1, 1 ];
            var ratios:Array = [ 0, 255 ];
            var matr:Matrix = new Matrix();
            matr.createGradientBox(bounds.width, bounds.height, Math.PI/2, 0, 0 );
            var sprMethod:String = SpreadMethod.PAD;
            
            background = new Sprite();
            boundsRectangle = new Shape();
            var g:Graphics = boundsRectangle.graphics;
            g.beginGradientFill( fType, colors, alphas, ratios, matr, sprMethod );
            g.drawRect(0, 0, bounds.width, graphBounds.height + padding);
            g.endFill();
            boundsRectangle.y = -padding;
            background.addChild(boundsRectangle);
            boundsRectangle.filters = new Array(dropShadow);
                
            // background = new Sprite();
            // boundsRectangle = new Shape();
            // boundsRectangle.graphics.beginFill(0x0000ff, 1);
            // boundsRectangle.graphics.drawRect(0, 0, bounds.width, bounds.height);
            // boundsRectangle.graphics.endFill();
            // background.addChild(boundsRectangle);
            
            // Hintergrund für Januar, Februar, ...
            var bla = new Shape();
            var g:Graphics = bla.graphics;
            matr.createGradientBox(bounds.width, 15, Math.PI/2, 0, 0 );
            g.beginGradientFill( fType, colors, alphas, ratios, matr, sprMethod );
            g.drawRect(0, 0, bounds.width, 15);
            g.endFill();
            background.addChild(bla);
            bla.y = graphBounds.height + 5;
            bla.filters = new Array(dropShadow);
            
            addChildAt(background, 0);
             
            // Titel des Diagrams (wird vom Hauptprogramm gesetzt)
             
            this.title = new TextField();
            //this.addChild(title);
            this.title.width = graphBounds.width;
            this.title.x = 0;
            this.title.y = 0;
            this.title.selectable = false;
            this.title.defaultTextFormat = titleFormat;
            this.title.text = "";
            
            this.date1 = new TextField();
            this.addChild(date1);
            this.date1.width = graphBounds.width;
            this.date1.x = 5;
            this.date1.y = -10;
            this.date1.selectable = false;
            this.date1.defaultTextFormat = titleFormat; 
            this.date1.text = "10.01.2010";
            
            //
            
            this.date2 = new TextField();
            this.addChild(date2);
            this.date2.width = graphBounds.width;
            this.date2.x = width - 85;
            this.date2.y = -10;
            this.date2.selectable = false;
            this.date2.defaultTextFormat = titleFormat;
            this.date2.text = "10.01.2010";
            
            // Die Achsenbeschriftung der Zeitachse
            this.dateAxis = new Sprite();
            this.dateAxis.x = 0;
            this.dateAxis.y = graphBounds.height;
            this.scrollView.content.addChild(dateAxis);
        }
        private function initFormats ():void
        {
            Font.registerFont(LabelFont);
             
            // Ein paar Textformatierungen
            titleFormat = new TextFormat();
            titleFormat.color = 0xbbbbbb;
            titleFormat.size = 14;
            titleFormat.bold = true;
            titleFormat.font = "Helvetica";
             
            axisFormat = new TextFormat();
            axisFormat.color = 0x2A2A2A;
            axisFormat.size = 14;
            axisFormat.font = "Helvetica";
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
            startdate = getDateForX(deltaX);
            enddate = getDateForX(deltaX + b.width);
            numberOfDays = getNumberOfDays();
            var data:Object = {
                "startdate":startdate,
                "enddate":enddate,
                "numberOfDays": numberOfDays
            };
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
        public function getNumberOfDays():Number
        {
			var span:Number = startdate.time - enddate.time;
			var days:Number = span / Dates.MS_DAY;
			return days;
        }
        public function getXForDate (date:Date):Number
        {
            var d:Date = date;
            var b:Rectangle = scrollView.getBoundingRectangle();
            var x:Number = MathsUtil.map(date.time, minDate.time, maxDate.time, 0, scrollView.getBoundingRectangle().width);
            return x;
        }
        public function getTimeScale ():Number
        {
            return this.timeScale;
        }
        private function onScroll (event:ScrollEvent):void
        {
            fireRangeChange();
            updateAxis();
        }
        private function onPinch (event:GestureEvent):void
        {
             
            if (timeScale + event.value * 5 > 1) {
                timeScale += event.value * 5;
            } else {
                timeScale = 1;
            }  
            pinchCenterX = (scrollView.fingers[0].x + scrollView.fingers[1].x) / 2;
            // Verhältnis vom Mittelpunkt der Finger zur Breite der Scrollview
            var ratio:Number = Math.abs(scrollView.content.x - pinchCenterX) / graph.width;
            var oldW:Number = graph.width;
            updateAxis();
            update();
            fireRangeChange();
             
            var newW:Number = graph.width;
            scrollView.content.x += (oldW - newW) * ratio;
            scrollView.updateScrollIndicators();
 
        }
        private function onTouchDown (event:TouchEvent):void
        {
 
        }
        private function onTouchUp (event:TouchEvent):void
        {
            pinchCenterX = 0;
            fireRangeChange();
        }
        private function parseData ():void
        {
            // Irgendwann mal schauen ob die Daten sortiert sind
            if (xAxis == "" && yAxis == "") parseFields();
            // Grenzwerte für die Interpolation
             
            this.maxYValue = 0;
            for each(var o:Object in data) {
                if (o[yAxis] > this.maxYValue) this.maxYValue = o[yAxis];
            }  
            this.minXValue = Number(data[0][xAxis]);
            this.minYValue = 0;
             
            this.minDate = MathsUtil.convertMySQLDateToActionscript(String(data[0][xAxis]));
            this.maxDate = MathsUtil.convertMySQLDateToActionscript(String(data[data.length-1][xAxis]));
            this.startdate = minDate;
            this.enddate = maxDate;
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
            fireRangeChange();
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
            
            var todayx:Number = getXForDate(today);
             
            graph.graphics.clear();
            graph.graphics.lineStyle(timeScale / 2, graphColor, 1, false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.BEVEL);
            graph.graphics.moveTo(0, 0);
 
            var deltaX:Number = 100;
            var bottom:Number = bounds.height - dateLabelHeight;
            for each (var o:Object in mapping) {
                //trace(todayx);
                //trace(o.x);
                if (todayx == o.x) {
                    graph.graphics.lineStyle(timeScale / 2, 0xff0000, 1, false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.BEVEL);
                } else {
                    graph.graphics.lineStyle(timeScale / 2, graphColor, 1, false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.BEVEL);
                }
                x = o.x * timeScale;
                y = o.y;
                graph.graphics.moveTo(x, bottom);
                graph.graphics.lineTo(x, bottom - y);
            }
            deltaX = Math.abs(scrollView.content.x);
            var d:Date = getDateForX(deltaX);
            //updateAxis();
        }
        private function updateAxis():void
        {
            // Den angezeigten Zeitraum berechnen und entscheiden welche Zeiteinteilung benutzt wird
            var span:Number = Dates.timeSpan(startdate, enddate);
            // bestehende Beschriftung löschen
            while (dateAxis.numChildren) {
                dateAxis.removeChildAt(0);
            }
            switch (span) {
                case 0:
                    var min:Date = getDateForX(Math.abs(scrollView.content.x));
                    var max:Date = getDateForX(Math.abs(scrollView.content.x) + scrollView.getBoundingRectangle().width);
                    while (min.fullYear <= max.fullYear) {
                        var label:TextField = new TextField();  
                        dateAxis.addChild(label);
                        label.width = dateLabelWidth;
                        label.x = getXForDate(min) * timeScale;
                        label.y = dateLabelPaddingY;
                        label.defaultTextFormat = axisFormat;
                        label.text = "" + String(min.fullYear);
                        label.selectable = false;
                        //label.setTextFormat(axisFormat);
                        min = Dates.addYears(min, 1);
                    }
                    break;
                // Monate
                case -1:
                    var min:Date = getDateForX(Math.abs(scrollView.content.x));
                    var minD:Date = Dates.roundTime(min, -1);
                    var max:Date = getDateForX(Math.abs(scrollView.content.x) + scrollView.getBoundingRectangle().width);
                    var maxD:Date = Dates.roundTime(max, -1);
                    while (minD <= maxD) {
                        var label:TextField = new TextField();  
                        dateAxis.addChild(label);
                        label.width = dateLabelWidth;
                        label.x = getXForDate(minD) * timeScale;
                        label.y = dateLabelPaddingY;
                        label.defaultTextFormat = axisFormat;
                        label.text = "" + Dates.monthName(minD.month);
                        label.selectable = false;
                        minD = Dates.addMonths(minD, 1);
                    }
                    break;
            }
        }
    }
}