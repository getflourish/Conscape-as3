package conscape.components
{
    import flash.display.MovieClip;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;    

    public class Tooltip extends MovieClip {
    	
    	public var background:MovieClip;
		public var label_txt:TextField;
		
		public function Tooltip() {
			visible = false;
		}
		
        public function set label ( s: String ) : void {        	
        	label_txt.autoSize = TextFieldAutoSize.LEFT;
        	label_txt.width = 200;
        	label_txt.multiline = label_txt.wordWrap = true;        	
        	label_txt.text = s;        	
        	background.width = Math.max( 100, label_txt.textWidth + 10);
        	background.height = label_txt.textHeight + 18;
        	background.y = Math.round( -background.height - 16 );
        	label_txt.y = background.y + 2;
        }
    }
}

