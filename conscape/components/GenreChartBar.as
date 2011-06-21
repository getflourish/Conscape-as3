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
    
    import flash.events.MouseEvent;
    import gl.events.TouchEvent;
    import id.core.TouchSprite;

    public class GenreChartBar extends TouchSprite
    {
        private var currentDataProvider:CurrentDataProvider;
        private var totalGenres:Object;
        private var chartHeight:Number;
        private var chartWidth:Number;
        private var chartLabels:Dictionary;
        private var bar:TouchSprite;
        private var chartRects:Dictionary;
		
		public function GenreChartBar(_chartHeight:Number, _chartWidth:Number, _currentDataProvider:CurrentDataProvider)
		{
		    this.chartHeight = _chartHeight;
		    this.chartWidth = _chartWidth;
            
            this.bar = new TouchSprite();
            
            this.addChild(bar);
            
            Font.registerFont(HelveticaNeueBold);
            this.chartLabels = new Dictionary();
            this.chartRects = new Dictionary();
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
            for (var genre:String in Genre.getGenreObject()) {
                var chartLabel:TextField = new TextField();
                chartLabel.antiAliasType = flash.text.AntiAliasType.ADVANCED;
                chartLabel.width = this.chartWidth;
                chartLabel.defaultTextFormat = chartLabelTextFormat;
            	chartLabel.text = Genre.getGenreObject()[genre]["name"];
                chartLabel.filters = new Array(dropShadow);
                chartLabel.mouseEnabled = false;
                this.chartLabels[genre] = chartLabel;
                this.addChild(chartLabel);
                chartLabel.x = 0;
                
                var chartRect:TouchSprite = new TouchSprite();
                chartRect.x = 0;
                chartRect.y = 0;
                chartRect.name = genre;
                this.bar.addChild(chartRect);
                this.chartRects[genre] = chartRect;
            }
            
            this.currentDataProvider = _currentDataProvider;
            this.currentDataProvider.addEventListener(CurrentDataProviderEvent.CHANGE, dataChangeCallback);
            
            this.bar.addEventListener(TouchEvent.TOUCH_TAP, onBarTap);
		}
		private function onBarTap (event:TouchEvent):void
        {
            if (this.currentDataProvider.getSelectedFilterGenre() && this.currentDataProvider.getSelectedFilterGenre()["id"] == event.target.name) {
                this.currentDataProvider.setSelectedFilterGenre(null);
            } else {
                this.currentDataProvider.setSelectedFilterGenre(Genre.getGenre(event.target.name));
            }
        }
		public function dataChangeCallback(event:CurrentDataProviderEvent):void
        {
            this.totalGenres = this.currentDataProvider.getTotalGenres();
            this.draw();
        }
        public function draw():void
        {
            var y:Number = 0;
            //this.bar.graphics.clear();
            for each(var genreName:String in Genre.ORDER) {
                var barHeight:Number = this.chartHeight * (this.totalGenres[genreName]["count"]/this.currentDataProvider.getTotalGenreCount());
                this.chartRects[genreName].graphics.clear();
                this.chartRects[genreName].y = y;
                this.chartRects[genreName].graphics.beginFill(this.totalGenres[genreName]["colour"], 100);
                this.chartRects[genreName].graphics.drawRect(0, 0, this.chartWidth, barHeight);
                this.chartRects[genreName].graphics.endFill();
                this.chartLabels[genreName].y = y + barHeight/2 - 11;
                y += barHeight;
            }
        }
    }
}

