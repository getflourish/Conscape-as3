package {
	
    import flash.display.MovieClip;
    import flash.events.MouseEvent;    
    
    import id.core.TouchMovieClip;

    /**
     * Sample Marker
     * @author David Knape
     */
    public class SampleMarker extends TouchMovieClip {
           
        private var _title : String;

        public function SampleMarker() {
        	stop();       
        	 	
        	buttonMode = true;
        	mouseChildren = false;
        	tabEnabled = false;        	
        	cacheAsBitmap = false;
        	
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
        	return '[SampleMarker] ' + title;
        }
    }
}