package conscape.components
{
    import flash.display.Shape;
    
    import conscape.events.*;
    import conscape.util.MathsUtil;
    
    public class CircleDisplay extends Shape
    {
		private var venue:Venue;
		private var currentDataProvider:CurrentDataProvider;
		private var radius:Number = 1;
		
        public function CircleDisplay(_venue:Venue, _currentDataProvider:CurrentDataProvider)
        {
            this.venue = _venue;
            this.currentDataProvider = _currentDataProvider;
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
                this.alpha = MathsUtil.map(eventData["numberEvents"], 0, this.currentDataProvider.getMaxNumberEvents(), 0.25, 1);
                var area:Number = 3;
                area = Math.sqrt(eventData["totalAttendance"]) * 50;
                // TODO: HACK
                if (eventData["prominentGenre"]["id"] == "andere") area /= 2;
                if (area < 3) area = 3;
                    
                this.setArea(area);
                
                this.graphics.beginFill(eventData["prominentGenre"]["colour"], 100);
                this.graphics.drawCircle(0, 0, this.radius);
                this.graphics.endFill();
            } else {
                this.setArea(0);
            }
        }
    }
}