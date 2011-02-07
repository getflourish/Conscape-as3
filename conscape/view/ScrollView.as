package conscape.view
{
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.TweenLite;
	
	import id.core.TouchSprite;
	
	import flash.display.*;
	import flash.filters.DropShadowFilter;
	import flash.geom.*;
	
	import gl.GestureLib;
	import gl.events.TouchEvent;
	import gl.events.GestureEvent;
	
	import conscape.events.*;
	
	public class ScrollView extends TouchSprite	{
		
	/**
	* Universell einsetzbarer Scroll-Bereich.
	* 
	* @param content  			Hält alle DisplayObjects, die gescrollt werden sollen
	* @param bounce				Legt fest ob über die Grenzen hinaus gescrollt werden kann und der content 
	* 							beim loslassen wieder zurückfedert.
	* @param directionalLock	FREE, VERTICAL oder HORIZONTAL
	* @param scrollEnabled		Legt fest ob gescrollt werden kann	
	* @param scrollsToTop		Legt fest ob die Ansicht bei einem reset nach oben scrollt
	* 
	* @param showsHorizontalScrollIndicator 
	* @param showsVerticalScrollIndicator
	* 
	* @param springF	0..1 = Stärke der Federwirkung
	* 
	* TODO: Scrollbars
	* 
	*/
		private var background:Sprite;
		private var bheight:Number;
		private var bounds:Sprite;
		private var bwidth:Number;
		private var diffX:Number;
		private var diffY:Number;
		private var horizontalScrollIndicator:Sprite;
		private var lastX:Number;
		private var lastY:Number;
		private var rectangle:Shape;
		private var scrolling:Boolean;
		private var scrollIndicatorThickness:Number = 10;
		private var speedFactor:Number = 5;
		private var springF:Number = 1.0;
		private var verticalScrollIndicator:Sprite;

		public static const FREE:String = "free";
		public static const HORIZONTAL:String = "horizontal";
		public static const VERTICAL:String = "vertical";
		
		public var bounceEnabled:Boolean = true;
		public var content:TouchSprite;
		public var directionalLock:String = FREE;
        public var fingers:Array;
		public var scalingEnabled:Boolean = false;
		public var scrollEnabled:Boolean = true;
		public var scrollsToTop:Boolean = true;
	  	public var showsHorizontalScrollIndicator:Boolean = false;
	  	public var showsVerticalScrollIndicator:Boolean = false;

		public function ScrollView(_width:Number, _height:Number, c:DisplayObject=null)
		{
			this.bwidth = _width; 
			this.bheight = _height;
			this.fingers = [];
		
			// Content, dem von außerhalb irgendwas hinzugefügt werden kann, was scrollbar sein soll
			this.content = new TouchSprite();
			this.addChild(content);
			if (c != null) this.content.addChild(c);
			
			// Grenzen
			bounds = new Sprite();
			bounds.addChild(getBoundingRectangleShape());
			addChild(bounds);
			content.mask = bounds;
			
			// Hintergrund als aktive Fläche damit man auch zwischen den Items scrollen kann
			background = new Sprite();
			background.alpha = 0;
			background.addChild(getBoundingRectangleShape());
			addChildAt(background, 0);
			
			// Listener aktivieren damit alles flutscht
			enableScrolling();
			createScrollIndicators();
		}
		private function calcFlickTargetX (dx: Number):Number
		{
			var destX:Number;
			if (content.width > bounds.width) {
				var rightBounds:Number = bounds.x + bounds.width;
				var rightContainer:Number = content.x + content.width;
				var dist:Number = rightContainer - rightBounds;
				if (dx > -content.x) {
					destX = 0;
				} else if (dx < -dist) {
					destX = -content.width + bounds.width;
				} else {
					destX = content.x + dx;
				}
			} else {
				destX = content.x;
			}
			return destX;
		}
		private function calcFlickTargetY (dy: Number):Number
		{
			var destY:Number;
			// Prüfen ob flick überhaupt möglich ist
			if (content.height > bounds.height) {
				var bottomBounds:Number = bounds.y + bounds.height;
				var bottomContainer:Number = content.y + content.height;
				var dist:Number = bottomContainer - bottomBounds;
				// Für den Fall, dass das Ziel über die Grenze hinausgeht	
				if (dy > -content.y) {
					// Zur oberen Grenze scrollen
					destY = 0;
				} else if (dy < -dist){
					// Zur unteren Grenze scrollen
					destY = -content.height + bounds.height;
				} else {
					// Innerhalb der Grenzen bewegen
					destY = content.y + dy;
				}
			}
			return destY;
		}
		private function calcScrollTargetX (dx: Number):Number
		{
			var destX:Number;
			var force:Number;
			
			if(content.x + dx <= 0 && content.x + dx> -content.width + bounds.width){
				// normales scrollen
				destX = content.x + dx; 
			} else if(content.x + dx <= -content.width + bounds.width) {
				// Feder rechts
				if (bounceEnabled) {
					force = force = 1 + (bounds.width - (content.width + content.x)) / 10;
					destX = content.x + dx / (1 + force * springF);
				} else {
					destX = content.x;
				}
			} else  {
				// Feder links
				if (bounceEnabled) {
					force = (1 + content.x) / 10;
					destX = content.x + dx / (1 + force * springF);
				} else {
					destX = content.x;
				}
			}	
			return destX;		
		}
		private function calcScrollTargetY (dy: Number):Number
		{
			var destY:Number;
			var force:Number;
			if (content.y + dy <= 0 && content.y + dy > -content.height + bounds.height){
				// normales scrollen
				destY = content.y + dy; 
			} else if (content.y + dy <= -content.height + bounds.height) {
				// Feder unten
				if(bounceEnabled){
					force = force = 1 + (bounds.height - (content.height + content.y)) / 10;
					destY = content.y + dy / (1 + force * springF);
				} else {
					destY = content.y;
				}
			} else {
				// Feder oben
				if (bounceEnabled) {
					force = (1 + content.y) / 10;
					destY = content.y + dy / (1 + force * springF);
				} else {
					destY = content.y;
				}
			}	
			return destY;
		}
		private function createScrollIndicators ():void
		{
			horizontalScrollIndicator = new Sprite();
			horizontalScrollIndicator.name = "hsi";
			addChild(horizontalScrollIndicator);
			
			verticalScrollIndicator = new Sprite();
			addChild(verticalScrollIndicator);
		}
		public function disableScrolling ():void 
		{
			this.scrollEnabled = false;
			removeEventListener(GestureEvent.GESTURE_FLICK, gestureFlickHandler);
			removeEventListener(TouchEvent.TOUCH_DOWN, scrollStart);
			removeEventListener(TouchEvent.TOUCH_UP, scrollEnd);
			removeEventListener(TouchEvent.TOUCH_MOVE, scroll);
			removeEventListener(GestureEvent.GESTURE_SCALE, onScale);			
		}
		public function isScrolling():Boolean 
		{
			return scrolling;
		}
		public function enableScrolling(lock:String=FREE):void 
		{
			this.scrollEnabled = true;
			this.directionalLock = lock;
			this.blobContainerEnabled = true;
			
			addEventListener(GestureEvent.GESTURE_FLICK, gestureFlickHandler);
			addEventListener(TouchEvent.TOUCH_DOWN, scrollStart);
			addEventListener(TouchEvent.TOUCH_UP, scrollEnd);
			addEventListener(TouchEvent.TOUCH_MOVE, scroll);
			addEventListener(GestureEvent.GESTURE_SCALE, onScale);
		}
		public function getBoundingRectangle():Rectangle
		{
		    var b:Rectangle = new Rectangle(0, 0, this.bwidth, this.bheight);
		    return b;
		}
		private function getBoundingRectangleShape():Shape 
		{
			var rectangle:Shape = new Shape();
			rectangle.graphics.beginFill(0x000000, 0);
			rectangle.graphics.drawRect(0, 0, this.bwidth, this.bheight);
			rectangle.graphics.endFill();
			return rectangle;
		}
		public function getHeight():Number
		{
			return this.bheight;
		}
		public function getWidth():Number
		{
			return this.bwidth;
		}
		private function gestureFlickHandler(event:GestureEvent):void 
		{
			var dx:Number = event.velocityX * speedFactor;
			var dy:Number = event.velocityY * speedFactor;
			var destX:Number = calcFlickTargetX(dx);
			var destY:Number = calcFlickTargetY(dy);
			tweenScrollTo(destX, destY);
		}
		private function hideScrollIndicators (instant:Boolean = false):void
		{
		    trace("hide");
			if(instant) {
				horizontalScrollIndicator.alpha = 0;
				verticalScrollIndicator.alpha = 0;				
			} else {
			 	TweenLite.to(horizontalScrollIndicator, 0.2, { alpha: 0 });
			 	TweenLite.to(verticalScrollIndicator, 0.2, { alpha: 0 });	
			}
		}
		private function onScale (event:GestureEvent):void
		{
			if (scalingEnabled) {
				content.scaleX += event.value;
				content.scaleY += event.value;
			}
		}
		public function reset():void
		{
			// Ganz nach oben scrollen
			if(scrollsToTop) TweenLite.to(content, 1, {y: 0});
			update();
		}
		private function scroll(event:TouchEvent):void 
		{
			var dx = event.stageX - lastX;
			lastX = event.stageX;
			var dy = event.stageY - lastY;
			lastY = event.stageY;
			var destX:Number = calcScrollTargetX(dx);
			var destY:Number = calcScrollTargetY(dy);
			scrollTo(destX, destY);	
		}
		private function scrollEnd(event:TouchEvent):void 
		{	
		    var index:Number = -1;
            for (var i:Number = 0; i < fingers.length; i++) {
                if (fingers[i] == event.tactualObject) {
                    index = i;
                }
            }
            if (index != -1) fingers.splice(index, 1);
            trace(fingers.length);
			// TODO: Irgendwann mal aufräumen
			
			if (fingers.length == 0) {
			    var destX, destY:Number;
    			var bounceX = true;
    			var bounceY = true;

    			if (!isScrolling()) hideScrollIndicators();

    			if(bounceEnabled){
    				if(content.x > 0){
    					// Nach links
    					destX = 0;
    				} else if (content.x < -content.width + bounds.width && content.width > this.bwidth){
    					// Nach rechts		
    					destX = -content.width + bounds.width;
    				} else if (content.x < -content.width + bounds.width && content.width < this.bwidth){
    					destX = 0;
    				} else {
    					destX = content.x;
    					bounceX = false;
    				}

    				if(content.y > 0){
    					// Nach oben
    					destY = 0;
    				} else if (content.y < -content.height + bounds.height && content.height > this.bheight){
    					// Nach unten	
    					destY = -content.height + bounds.height;
    				} else if (content.y < -content.height + bounds.height && content.height < this.bheight){
    					destY = 0;
    				} else {
    					destY = content.y;
    					bounceY = false;
    				}

    				switch(directionalLock) {
    					case FREE:
    						if (bounceX || bounceY) tweenScrollTo(destX, destY, 0.5);
    						break;
    					case HORIZONTAL:
    						if (bounceX) tweenScrollTo(destX, destY, 0.5);
    						break;
    					case VERTICAL:
    						if(bounceY) tweenScrollTo(destX, destY, 0.5);
    						break;
    				}
    			}
    			addEventListener(TouchEvent.TOUCH_DOWN, scrollStart);
    			removeEventListener(GestureEvent.GESTURE_FLICK, gestureFlickHandler);
    		    removeEventListener(TouchEvent.TOUCH_UP, scrollEnd);	
    			removeEventListener(TouchEvent.TOUCH_MOVE, scroll);
			} else {
             
			}
		}
		private function scrollStart (event:TouchEvent):void 
		{
		    fingers.push(event.tactualObject);

		    if (fingers.length == 1) {
		        // TODO: Irgendwie gibt's noch ein Problem, wenn ein Tween läuft und man dann normal scrollt
    			TweenLite.killTweensOf(content);
    			scrolling = false;
    			lastX = event.stageX;
    			lastY = event.stageY;
    			addEventListener(GestureEvent.GESTURE_FLICK, gestureFlickHandler);
    			addEventListener(TouchEvent.TOUCH_UP, scrollEnd);
    			addEventListener(TouchEvent.TOUCH_MOVE, scroll);
		    } else { 
                removeEventListener(TouchEvent.TOUCH_MOVE, scroll);
                removeEventListener(GestureEvent.GESTURE_FLICK, gestureFlickHandler);
                removeEventListener(TouchEvent.TOUCH_DOWN, scrollStart);
		    }
		}
		public function scrollTo (destX:Number, destY:Number):void 
		{
			showScrollIndicators();
			if (scrollEnabled) {
				scrolling = true;
				switch(directionalLock){
					case HORIZONTAL:
						content.x = destX;	
						destY = content.y;
						break;
					case VERTICAL:
						content.y = destY;
						destX = content.x;
						break;
					case FREE:
						content.x = destX;
						content.y = destY;
						break;
				}
				dispatchEvent(new ScrollEvent(ScrollEvent.SCROLL, {"x": destX, "y": destY}));
				scrolling = false;
				updateScrollIndicators();
			}
		}
		public function setBounds(width:Number, height:Number):void 
		{
			this.bwidth = width;
			this.bheight = height;
			
			TweenLite.to(bounds, 1, {width:bwidth, height:bheight});
			TweenLite.to(background, 1, {width:bwidth, height:bheight});
		}
		public function set scrollSpeed (speed:Number):void
		{
			this.speedFactor = speed;
		}
		private function showScrollIndicators ():void
		{
			if (showsHorizontalScrollIndicator)	horizontalScrollIndicator.alpha = 0.5;
			if (showsVerticalScrollIndicator) verticalScrollIndicator.alpha = 0.5;
		}
		public function tweenScrollTo (destX:Number, destY:Number, duration:Number=1):void 
		{
			if (scrollEnabled) {
				switch (directionalLock) {
					case HORIZONTAL:
						destY = content.y;
						break;
					case VERTICAL:
						destX = content.x;
						break;
				}
				scrolling = true;
				showScrollIndicators();
				TweenLite.to(content, duration, { x: destX, y: destY, ease:Circ.easeOut, onComplete:function():void {
					scrolling = false;
					// updateScrollIndicators();
					hideScrollIndicators();
				}});
				dispatchEvent(new ScrollEvent(ScrollEvent.SCROLL, {"x": destX, "y": destY}));
			}
		}
		public function update ():void 
		{
			hideScrollIndicators(true);
			if (this.content.height > this.bheight || this.content.width > this.bwidth) {
				enableScrolling(directionalLock);
			} else {
				disableScrolling();
			}
			updateScrollIndicators();
			hideScrollIndicators(true);
		}
		public function updateScrollIndicators ():void
		{
			if (showsVerticalScrollIndicator) {
			    showScrollIndicators();
				var sy:Number = (-content.y / content.height) * bounds.height;
				var h:Number = (bounds.height / content.height) * bounds.height;
				// Unterer Rand drüber hinaus
				if (sy > bounds.height - h) {
					h = h - (sy - (bounds.height - h));
					sy = bounds.height - h;
				} else if (sy < 0) {
					// Oberer Rand drüber
					h = h + sy;
					sy = 0;
				}
				verticalScrollIndicator.graphics.clear();
				verticalScrollIndicator.graphics.beginFill(0x000000, 1);
				verticalScrollIndicator.graphics.drawRoundRect(bounds.width - scrollIndicatorThickness, 0, scrollIndicatorThickness, h, 10);
				verticalScrollIndicator.graphics.endFill();
			
				TweenLite.to(verticalScrollIndicator, 1, {y: sy, ease:Circ.easeOut});
			}
			
			if (showsHorizontalScrollIndicator) {
			    showScrollIndicators();
				var sx:Number = (-content.x / content.width) * bounds.width;
				var w:Number = (bounds.width / content.width) * bounds.width;
				// Rechter Rand
				if (sx > bounds.width - w) {
					w = w - (sx - (bounds.width - w));
					sx = bounds.width - w;
                // Linker Rand
				} else if (sx < 0) {
					w = w + sx;
					sx = 0;
				}
				horizontalScrollIndicator.graphics.clear();
				horizontalScrollIndicator.graphics.beginFill(0x000000, 1);
				horizontalScrollIndicator.graphics.drawRoundRect(0, bounds.height - scrollIndicatorThickness, w, scrollIndicatorThickness, 10);
				horizontalScrollIndicator.graphics.endFill();
				
                TweenLite.to(horizontalScrollIndicator, 1, {x: sx, ease:Circ.easeOut});	
			}
		}
		/* 	Das geht leider nicht so einfach. Das Weiterleiten funktioniert so zwar aber
			das ganze wird problematisch, wenn man irgendwann die ScrollView entfernen
			will und background, content etc. nicht über removeChild() erreichbar sind. 
		
		public override function addChild (child:DisplayObject):DisplayObject
		{
			content.addChild(child);
			return child;
		}
		public override function addChildAt (child:DisplayObject, index:int):DisplayObject
		{
			content.addChildAt(child, index);
			return child;
		}	
		public override function getChildIndex (child:DisplayObject):int 
		{
			return content.getChildIndex(child);
		}
		public override function get numChildren ():int
		{
			return content.numChildren;
		}
		public override function removeChild (child:DisplayObject):DisplayObject
		{
			content.removeChild(child);
			return child;
		}	
		public override function removeChildAt (index:int):DisplayObject
		{
			var remove:DisplayObject = content.getChildAt(index);
			content.removeChild(remove);
			return remove;
		}
		public override function setChildIndex (child:DisplayObject, index:int):void
		{
			content.setChildIndex(child, index);

		}
		*/
	}	
}

