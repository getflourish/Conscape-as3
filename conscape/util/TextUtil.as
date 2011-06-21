package conscape.util
{
	import flash.text.TextField;
    import flash.text.TextFormat;
    
    public class TextUtil
    {
    	public static function createTextFormat (props:Object):TextFormat
    	{
    	    var textFormat:TextFormat = new TextFormat();
    	    for (var key:String in props) {
               textFormat[key] = props[key];
    	    }
    	    return textFormat;
    	}
		public static function truncateTextField (textField:TextField, concatText:String="..."):String
		{
			// Kürzt einen String, sodass er in das gegebene TextFeld passt
			if (textField.textWidth > textField.width) {
				var initWidth:Number = textField.textWidth;
				textField.appendText(concatText);
				var concatWidth:Number = textField.textWidth - initWidth;
				var activeWidth:Number = textField.width - concatWidth;			
				textField.text = textField.text.substr(0, (textField.text.length - concatText.length))

	            while (textField.textWidth > activeWidth) {
					textField.text = textField.text.substr(0, (textField.text.length - 1));
	            }
				textField.appendText(concatText);
				return textField.text;
			} else {
				return textField.text;
			}
		}
    }
}