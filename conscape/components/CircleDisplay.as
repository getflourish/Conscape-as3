package conscape.components
{
    import flash.display.Shape;
    
    public class CircleDisplay extends Shape
    {
		private var genreData:Object;
		private var prominentGenre:Object;
		private var radius:Number = 1;
		
        public function CircleDisplay(_genreData:Object)
        {
            this.setData(_genreData);
        }
        public function setData(_genreData:Object):void
        {
            this.genreData = _genreData;
            this.prepareDrawing();
        }
        public function getData():Object
        {
            return this.genreData;
        }
        private function prepareDrawing():void
        {
            this.prominentGenre = {"count": -1};
            for each(var genre:Object in this.genreData) {
                if (genre["count"] > this.prominentGenre["count"]) {
                    this.prominentGenre = genre;
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
            this.graphics.beginFill(this.prominentGenre["colour"], 100);
            this.graphics.drawCircle(this.radius*-1, this.radius*-1, this.radius);
            this.graphics.endFill();
        }
    }
}