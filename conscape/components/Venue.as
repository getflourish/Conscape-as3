package {
	
    import flash.display.MovieClip;
    import flash.events.MouseEvent;    
    
    import id.core.TouchMovieClip;

    public class Venue extends TouchMovieClip {
           
        private var _title : String;
        private var pie:PieChart;

        public function Venue() {
        	stop();       
        	 	
        	buttonMode = true;
        	mouseChildren = false;
        	tabEnabled = false;        	
        	cacheAsBitmap = true;
        	
        	this.pie = new PieChart([1]);
        	
        	addEventListener( MouseEvent.ROLL_OVER, bringToFront, true );
        }
                
        public function get title () : String {
        	return _title;
        }
        
        public function set title (s:String) : void {
        	_title = s;
        }
                
        protected function bringToFront(e:MouseEvent) : void {
       		parent.swapChildrenAt(parent.getChildIndex(this), parent.numChildren - 1);
        }
        
        override public function toString() : String {
        	return '[Venue] ' + title;
        }
    }
}