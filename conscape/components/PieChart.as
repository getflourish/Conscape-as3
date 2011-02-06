package
{
    import flash.display.Shape;
    
    public class PieChart extends Shape
    {
		private static var CONVERT_TO_RADIANS:Number = Math.PI / 180;
		private var chartData:Array;
		private var percentages:Array;
		private var shapes:Array;
		private var colours:Array = [
		    0xFF0000,
		    0x00FF00,
		    0x0000FF
		];
		private var radius:Number;
		
        public function PieChart(_chartData:Array)
        {
            this.setData(_chartData);
            
        }
        public function setData(_chartData:Array):void
        {
            this.chartData = _chartData;
            this.calculatePercentages();
        }
        public function getData():Array
        {
            return this.chartData;
        }
        public function addData(_chartData):void
        {
            if (_chartData is Array) {
                this.chartData = this.chartData.concat(_chartData);
            } else {
                this.chartData.push(_chartData);
            }
            this.calculatePercentages();
        }
        private function calculatePercentages():void
        {
            var total:Number = 0;
            for each(var amount:Number in this.chartData) {
                total += amount;                                
            }
            this.percentages = [];
            var ratio = 100/total;
            for each(var amount2:Number in this.chartData) {
                this.percentages.push(amount2*ratio/100);
            }
        }
        public function draw():void
        {
            this.graphics.clear();
            var rotation:Number = 0;
            for (var i:Number = 0; i < this.percentages.length; i++) {
                if (this.percentages[i] == 0) continue;
                PieChart.drawWedge(this, 50, this.percentages[i], this.colours[i], rotation);
                rotation += 360 * (this.percentages[i]);
            }
        }
        public static function drawWedge(_shape:Shape, _radius:Number, _percent:Number, _colour:uint = 0xFF0000, _rotationOffset:Number = 0):void
        {      
            var _arc:Number = 360*_percent
            _shape.graphics.beginFill (_colour,100);

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