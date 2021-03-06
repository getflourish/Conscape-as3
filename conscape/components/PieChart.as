package conscape.components
{
    import flash.display.Shape;
    
    import conscape.events.*;
    
    public class PieChart extends Shape
    {
		private static var CONVERT_TO_RADIANS:Number = Math.PI / 180;
		private var venue:Venue;
		private var currentDataProvider:CurrentDataProvider;
		private var radius:Number = 1;
		
        public function PieChart(_venue:Venue, _currentDataProvider:CurrentDataProvider)
        {
            this.venue = _venue;
            this.currentDataProvider = _currentDataProvider;
        }
        private function calculatePercentages(eventData:Object):Array
        {
            var total:Number = 0;            
            for each(var genreName:String in Genre.ORDER) {
                total += eventData["genres"][genreName]["count"];   
            }
            var percentages:Array = [];
            var ratio = 100/total;
            for each(var genreName:String in Genre.ORDER) {
                if (eventData["genres"][genreName]["count"] > 0) {
                    percentages.push({
                        "id": genreName,
                        "percentage": eventData["genres"][genreName]["count"]*ratio/100
                    });
                }
            }
            return percentages;
        }
        public function setRadius(_radius:Number):void
        {
            this.radius = _radius;
        }
        public function getRadius():Number
        {
            return this.radius;
        }
        public function setArea(_area:Number):void
        {
            this.radius = Math.sqrt(_area/Math.PI);
        }
        public function getArea():Number
        {
            return Math.pow(this.radius, 2) * Math.PI;
        }
        public function draw():void
        {
            this.graphics.clear();
            var eventData:Object = venue.getEventData();
            if (eventData) {
                var area:Number = 3;
                area = Math.sqrt(eventData["totalAttendance"]) * 50;
                if (area < 3) area = 3;
                    
                this.setArea(area);
                
                var rotation:Number = 0;
                for each(var percentage:Object in this.calculatePercentages(eventData)) {
                    PieChart.drawWedge(this, this.radius, percentage["percentage"], eventData["genres"][percentage["id"]]["colour"]);
                    rotation += 360 * percentage["percentage"];
                }
            } else {
                this.setArea(0);
            }
        }
        public static function drawWedge(_shape:Shape, _radius:Number, _percent:Number, _colour:uint = 0xFF0000, _rotationOffset:Number = 0):void
        {      
            var _arc:Number = 360*_percent
            _shape.graphics.beginFill(_colour,100);

            var segAngle, theta, angle, angleMid, segs, ax, ay, bx, by, cx, cy;
            _shape.graphics.moveTo(0, 0);
            // Flash uses 8 segments per circle, to match that, we draw in a maximum
            // of 45 degree segments. First we calculate how many segments are needed
            // for our _arc.
            segs = Math.ceil(Math.abs(_arc)/45);
            // Now calculate the sweep of each segment.
            segAngle = _arc/segs;
            // The math requires radians rather than degrees. To convert from degrees
            // use the formula (degrees/180)*Math.PI to get radians.
            theta = -(segAngle/180)*Math.PI;
            // convert angle _startAngle to radians
            angle = -(_rotationOffset/180)*Math.PI;
            // draw the curve in segments no larger than 45 degrees.
            if (segs>0) {
                // draw a line from the center to the start of the curve
                ax = Math.cos(_rotationOffset/180*Math.PI)*_radius;
                ay = Math.sin(-_rotationOffset/180*Math.PI)*_radius;
                _shape.graphics.lineTo(ax, ay);
                // Loop for drawing curve segments
                for (var i:int = 0; i<segs; i++) {
                    angle += theta;
                    angleMid = angle-(theta/2);
                    bx = Math.cos(angle)*_radius;
                    by = Math.sin(angle)*_radius;
                    cx = Math.cos(angleMid)*(_radius/Math.cos(theta/2));
                    cy = Math.sin(angleMid)*(_radius/Math.cos(theta/2));
                    _shape.graphics.curveTo(cx, cy, bx, by);
                }
                // close the wedge by drawing a line to the center
                _shape.graphics.lineTo(0, 0);
            }
        }
    }
}