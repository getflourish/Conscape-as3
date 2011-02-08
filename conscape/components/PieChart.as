package conscape.components
{
    import flash.display.Shape;
    
    public class PieChart extends Shape
    {
		private static var CONVERT_TO_RADIANS:Number = Math.PI / 180;
		private var genreData:Object;
		private var percentages:Array;
		private var colours:Array;
		
		private var radius:Number = 1;
		
        public function PieChart(_genreData:Object)
        {
            this.setData(_genreData);
            this.colours = Genre.COLOURS;
        }
        public function setData(_genreData:Object):void
        {
            this.genreData = _genreData;
            this.calculatePercentages();
        }
        public function getData():Object
        {
            return this.genreData;
        }
        private function calculatePercentages():void
        {
            var total:Number = 0;            
            for each(var genreName:String in Genre.ORDER) {
                total += genreData[genreName]["count"];   
            }
            this.percentages = [];
            var ratio = 100/total;
            for each(var genreName:String in Genre.ORDER) {
                if (genreData[genreName]["count"] > 0) {
                    this.percentages.push(genreData[genreName]["count"]*ratio/100);
                } else {
                    this.percentages.push(0);
                }
            }
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
            var rotation:Number = 0;
            for (var i:Number = 0; i < this.percentages.length; i++) {
                if (this.percentages[i] == 0) continue;
                PieChart.drawWedge(this, this.radius, this.percentages[i], this.colours[i], rotation);
                rotation += 360 * (this.percentages[i]);
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