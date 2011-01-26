package conscape.util
{
    public class MathsUtil
    {
        public static function normalize(value:Number, minimum:Number, maximum:Number):Number {
            return (value - minimum) / (maximum - minimum);
        }
        public static function interpolate(normValue:Number, minimum:Number, maximum:Number):Number {
            return minimum + (maximum - minimum) * normValue;
        }
        public static function map(value:Number, min1:Number, max1:Number, min2:Number, max2:Number):Number 
        {
            return interpolate(normalize(value, min1, max1), min2, max2);
        }
        public static function isDate(s:String):Boolean
		{
			if (!isNaN(Number(s))) return false;
			if (!isNaN(Date.parse(s))) return true;
			return false;
		}
		public static function convertMySQLDateToActionscript(s:String):Date {
			var a:Array = s.split('-');
			return new Date( a[0], a[1] - 1, a[2] );
		}
		public static function convertMySQLTimeStampToASDate(time:String):Date {
			var pattern:RegExp = /[: -]/g;
			time = time.replace( pattern, ',' );
			var timeArray:Array = time.split( ',' );
			var date:Date = new Date(timeArray[0], timeArray[1]-1, timeArray[2], timeArray[3], timeArray[4], timeArray[5]);
			return date as Date;
		}
    }
}