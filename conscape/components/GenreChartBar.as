package conscape.components
{
    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.text.AntiAliasType;
    import flash.text.Font;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.utils.Dictionary;
    import flash.filters.BitmapFilter;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.DropShadowFilter;
    
    import conscape.events.*;

    public class GenreChartBar extends Sprite
    {
        private var currentDataProvider:CurrentDataProvider;
        private var totalGenres:Object;
        private var chartHeight:Number;
        private var chartWidth:Number;
        private var chartLabels:Dictionary;
        private var bar:Shape;
		
		public function GenreChartBar(_chartHeight:Number, _chartWidth:Number, _currentDataProvider:CurrentDataProvider)
		{
		    this.chartHeight = _chartHeight;
		    this.chartWidth = _chartWidth;
            
            this.bar = new Shape();
            this.addChild(bar);
            
            Font.registerFont(HelveticaNeueBold);
            this.chartLabels = new Dictionary();
            var chartLabelTextFormat:TextFormat = new TextFormat();
            chartLabelTextFormat.size = 15;
            chartLabelTextFormat.align = TextFormatAlign.CENTER;
            chartLabelTextFormat.bold = true;
            chartLabelTextFormat.color = 0xFFFFFF;
            chartLabelTextFormat.kerning = true;
            chartLabelTextFormat.font = "Helvetica Neue";
            var dropShadow:DropShadowFilter = new DropShadowFilter();
            dropShadow.color = 0x000000;
            dropShadow.blurX = 3;
            dropShadow.blurY = 3;
            dropShadow.angle = 90;
            dropShadow.alpha = 0.3;
            dropShadow.distance = 2;
            dropShadow.quality = BitmapFilterQuality.HIGH;
            for (var genre:Object in Genre.getGenreObject()) {
                var chartLabel:TextField = new TextField();
                chartLabel.antiAliasType = flash.text.AntiAliasType.ADVANCED;
                chartLabel.width = 100;
                chartLabel.defaultTextFormat = chartLabelTextFormat;
            	chartLabel.text = Genre.getGenreObject()[genre]["name"];
                chartLabel.filters = new Array(dropShadow);
                this.chartLabels[genre] = chartLabel;
                this.addChild(chartLabel);
                chartLabel.x = 0;
            }
            
            this.currentDataProvider = _currentDataProvider;
            this.currentDataProvider.addEventListener(CurrentDataProviderEvent.CHANGE, dataChangeCallback);
		}
		public function dataChangeCallback(event:CurrentDataProviderEvent):void
        {
            this.totalGenres = this.currentDataProvider.getTotalGenres();
            this.draw();
        }
        public function draw():void
        {
            this.bar.graphics.clear();
            var y:Number = 0;
            for each(var genreName:String in Genre.ORDER) {
                var barHeight:Number = this.chartHeight * (this.totalGenres[genreName]["count"]/this.currentDataProvider.getTotalGenreCount());
                this.bar.graphics.beginFill(this.totalGenres[genreName]["colour"], 100);
                this.bar.graphics.drawRect(0, y, this.chartWidth, barHeight);
                this.bar.graphics.endFill();
                this.chartLabels[genreName].y = y + barHeight/2 - 11;
                y += barHeight;
            }
        }
    }
}

