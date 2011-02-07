package conscape.components
{
    import conscape.events.*;
    import conscape.util.MathsUtil;
    import conscape.util.Dates;
    import conscape.view.ScrollView;
    
    import flash.display.Sprite;
    import flash.display.Graphics;
    import flash.display.LineScaleMode;
    import flash.display.CapsStyle;
    import flash.display.JointStyle;
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
        private var dateLabelWidth:Number = 50;
        private var dateLabelPaddingY:Number = 5;
        private var dateAxis:Sprite;
        private var eventsForDate:Dictionary;
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
        private var padding:Number = 15;
        private var pinchCenterX:Number = 0;
        private var startdate:Date;
        private var tage:Dictionary;
        private var timeScale:Number = 1;
        private var title:TextField;
        private var titleFormat:TextFormat;
        private var scrollView:ScrollView;
        private var xAxis:String;
        private var yAxis:String;
        private var dateForX:Array;
        private var dayWidth:Number;
        
        public var graphColor:uint = 0x000000;
        
        public function Timeline (data:Array, width:Number=200, height:Number=100, padding:Number=15):void
        {
            debugger = new MonsterDebugger(this);
            
            this.data = data;
            this.fields = [];
            this.padding = padding;
            this.bounds = new Rectangle(padding, padding, width-2*padding, height-2*padding);
            this.graphBounds = new Rectangle(padding, padding, width-2*padding, height - dateLabelHeight - 2*padding);
            this.initWidth = width;
            this.initHeight = height;
            this.initFormats();
            init();
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
            this.scrollView.addEventListener(GestureEvent.GESTURE_SCALE, onPinch);
            this.scrollView.addEventListener(TouchEvent.TOUCH_UP, onTouchUp);
            this.scrollView.addEventListener(TouchEvent.TOUCH_DOWN, onTouchDown);
            this.scrollView.addEventListener(ScrollEvent.SCROLL, onScroll);
            this.addChild(scrollView);
            
            // Hintergrund
            background = new Sprite();
			boundsRectangle = new Shape();
			boundsRectangle.graphics.beginFill(0x0000ff, 0.1);
			boundsRectangle.graphics.drawRect(0, 0, bounds.width, bounds.height);
			boundsRectangle.graphics.endFill();
			background.addChild(boundsRectangle);
			scrollView.content.addChild(background);
			
			// Titel des Diagrams (wird vom Hauptprogramm gesetzt)
            
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
		private function initFormats ():void
		{
		    Font.registerFont(LabelFont);
		    
		    // Ein paar Textformatierungen
		    titleFormat = new TextFormat();
            titleFormat.color = 0x000000;
            titleFormat.size = 18;
            titleFormat.font = "Helvetica";
            
            axisFormat = new TextFormat();
            axisFormat.color = graphColor;
            axisFormat.size = 14;
            axisFormat.font = "Helvetica";
		}
        public function initMapping ():void
        {      
            eventsForDate = new Dictionary();      
            dateForX = [];
            
            // this.parseData();
            trace(data[0]["startdate"]);
            for each(var row:Object in data) {
                eventsForDate[row["startdate"]] = row;
            }

            // Anzahl aller Tage
            var gesamteAnzahlTage:Number = 0;
            var now:Date = startdate;
            tage = new Dictionary();
            while (now <= enddate) {
                gesamteAnzahlTage += 1;
                var tag:Object = {}
                if (eventsForDate[MathsUtil.getMySQLDate(now)]) {
                    tag = eventsForDate[MathsUtil.getMySQLDate(now)];
                }
                tage[MathsUtil.getMySQLDate(now)] = tag;
                now = Dates.addDays(now, 1);
            }
            eventsForDate = null;

            dayWidth = scrollView.getBoundingRectangle().width / gesamteAnzahlTage;
            var d:Number = 1;
            now = startdate;
            while (now <= enddate) {
                var n:String = MathsUtil.getMySQLDate(now);
                var x:Number = dayWidth * d;
                dateForX.push(n);
                tage[n]["x"] = x;
                if (tage[n]["anzahl"]) {
                    tage[n]["y"] = (tage[n]["anzahl"] / maxYValue) * graphBounds.height;
                } else {
                    tage[n]["y"] = 0;
                }
                // Noch mehr Sachen machen? Keine Ahnung.
                now = Dates.addDays(now, 1);
                d++;
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
            startdate = MathsUtil.convertMySQLDateToActionscript(getDateForX(deltaX));
            enddate = MathsUtil.convertMySQLDateToActionscript(getDateForX(deltaX + b.width));
            var data:Object = {"startdate":startdate, "enddate":enddate};
            this.dispatchEvent(new TimelineEvent(TimelineEvent.RANGECHANGE, data));
        }
        public function getDateForX (x:Number):String
        {
            var tag:Number = Math.floor(x / (dayWidth*timeScale));
            if (tag >= dateForX.length) tag = dateForX.length-1;
            return dateForX[tag];
            
            //var b:Rectangle = scrollView.getBoundingRectangle();
            //x = MathsUtil.map(x, 0, graph.width, minDate.getTime(), maxDate.getTime());
            //var d:Date = new Date(x);
            /*return d;*/
        }
        public function getXForDate (date:Date):Number
        {
            var d:Date = date;
            var b:Rectangle = scrollView.getBoundingRectangle();
            x = MathsUtil.map(x, 0, graph.width, minDate.getTime(), maxDate.getTime());
            return x;
        }
        public function getTimeScale ():Number
        {
            return this.timeScale;
        }
        private function onScroll (event:ScrollEvent):void
        {
            fireRangeChange();
        }
        private function onPinch (event:GestureEvent):void 
        {
            
            if (timeScale >= 1) {
                timeScale += event.value * 50;
            } else {
                timeScale = 1;
            }  
            pinchCenterX = (scrollView.fingers[0].x + scrollView.fingers[1].x) / 2;
            // Verhältnis vom Mittelpunkt der Finger zur Breite der Scrollview
            var ratio:Number = Math.abs(scrollView.content.x - pinchCenterX) / scrollView.width;
            var oldW:Number = scrollView.width;
            fireRangeChange();
            update();
            
            var newW:Number = scrollView.width;
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
            update();
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
            trace(data[0][xAxis]);
            this.minDate = MathsUtil.convertMySQLDateToActionscript(data[0][xAxis]);
            this.maxDate = MathsUtil.convertMySQLDateToActionscript(data[data.length-1][xAxis]);
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
                       
            var now:Date = startdate;
            drawBounds(scrollView.getBoundingRectangle().width * timeScale, scrollView.getBoundingRectangle().height);
            // Balken zeichnen
            var bottom:Number = scrollView.getBoundingRectangle().height - dateLabelHeight;
            
            graph.graphics.clear();
            graph.graphics.lineStyle(timeScale / 2, graphColor, 1, false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.BEVEL);
            while (now <= enddate) {
                var n:String = MathsUtil.getMySQLDate(now);
                if (tage[n]) {
                    var x:Number = tage[n]["x"] * timeScale;
                    var y:Number = tage[n]["y"];
                    graph.graphics.moveTo(x, bottom);
                    graph.graphics.lineTo(x, bottom - y);

                    //if (now.dayOfMonth == 1) {
                        // malLabel();
                    //}
                }
                now = Dates.addDays(now, 1);
            }
            
        }
        /*private function updateAxis():void
        {
            // Den angezeigten Zeitraum berechnen und entscheiden welche Zeiteinteilung benutzt wird
            var span:Number = Dates.timeSpan(start, end);
            trace(start + " / " + span);
            // bestehende Beschriftung löschen
            while (dateAxis.numChildren) {
            	dateAxis.removeChildAt(0);
            }
            // Schauen wieviele Jahre es im Zeitraum gibt und in gleichen Abständen Jahreszahlen an die Achse schreiben
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

                dateLabel.setTextFormat(axisFormat);
                
                x += spacing;
            }
        }
        */
    }
}