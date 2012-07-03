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
    import gs.TweenLite;

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
            
            Font.registerFont(LabelFont);
            this.chartLabels = new Dictionary();
            this.chartRects = new Dictionary();
            var chartLabelTextFormat:TextFormat = new TextFormat();
            chartLabelTextFormat.size = 15;
            chartLabelTextFormat.align = TextFormatAlign.CENTER;
            chartLabelTextFormat.bold = true;
            chartLabelTextFormat.color = 0xFFFFFF;
            chartLabelTextFormat.kerning = true;
            chartLabelTextFormat.font = "Helvetica";
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
            this.currentDataProvider.toggleSelectionOfGenre(event.target.name);
        }
		public function dataChangeCallback(event:CurrentDataProviderEvent):void
        {
            this.totalGenres = this.currentDataProvider.getTotalGenres();
            this.draw();
        }
        public function draw():void
        {
            var y:Number = 0;
            for each(var genreId:String in Genre.ORDER) {
                if (this.currentDataProvider.isSelectedGenre(genreId)) {
                    TweenLite.to(this.chartRects[genreId], 0.5, {alpha:0.8});
                    TweenLite.to(this.chartLabels[genreId], 0.5, {alpha:1});
                } else {
                    TweenLite.to(this.chartRects[genreId], 0.5, {alpha:0.25});
                    TweenLite.to(this.chartLabels[genreId], 0.5, {alpha:1});
                }
                var barHeight:Number = this.chartHeight * (this.totalGenres[genreId]["count"]/this.currentDataProvider.getTotalGenreCount());
                this.chartRects[genreId].graphics.clear();
                this.chartRects[genreId].y = y;
                this.chartRects[genreId].graphics.beginFill(this.totalGenres[genreId]["colour"], 100);
                this.chartRects[genreId].graphics.drawRect(0, 0, this.chartWidth, barHeight);
                this.chartRects[genreId].graphics.endFill();
                this.chartLabels[genreId].y = y + barHeight/2 - 11;
                // hide label if genre has less than 2%
                if (this.totalGenres[genreId]["count"]/this.currentDataProvider.getTotalGenreCount() < 0.02) {
                    this.chartLabels[genreId].visible = false;
                } else {
                    this.chartLabels[genreId].visible = true;
                }
                y += barHeight;
            }
        }
    }
}

