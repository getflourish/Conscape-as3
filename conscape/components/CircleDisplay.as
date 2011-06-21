package conscape.components
{
    import flash.display.Shape;
    import conscape.events.*;
    
    public class CircleDisplay extends Shape
    {
		private var genreData:Object;
		private var venue:Venue;
		private var currentDataProvider:CurrentDataProvider;
		private var radius:Number = 1;
		
        public function CircleDisplay(_venue:Venue, _currentDataProvider:CurrentDataProvider, _genreData:Object)
        {
            this.venue = _venue;
            this.currentDataProvider = _currentDataProvider;
            this.setData(_genreData);
        }
        public function setData(_genreData:Object):void
        {
            this.genreData = _genreData;
        }
        public function getData():Object
        {
            return this.genreData;
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
            if (this.venue.getEventData("prominentGenre")) {
                this.graphics.beginFill(this.venue.getEventData("prominentGenre")["colour"], 100);
                this.graphics.drawCircle(0, 0, this.radius);
                this.graphics.endFill();
            }
        }
    }
}