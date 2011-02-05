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
		public static function convertMySQLDateToActionscript(s:String):Date 
		{
			var a:Array = s.split('-');
			return new Date( a[0], a[1] - 1, a[2] );
		}
		public static function convertMySQLTimeStampToASDate(time:String):Date 
		{
			var pattern:RegExp = /[: -]/g;
			time = time.replace( pattern, ',' );
			var timeArray:Array = time.split( ',' );
			var date:Date = new Date(timeArray[0], timeArray[1]-1, timeArray[2], timeArray[3], timeArray[4], timeArray[5]);
			return date as Date;
		}
		private static function prependZero( n:Number ):String 
		{
			var s:String = ( n < 10 ) ? '0' + n : n.toString();
			return s;
		}
		public static function convertASDateToMySQLTimestamp( d:Date ):String 
		{
			var s:String = d.fullYear + '-';
			s += prependZero(d.month + 1) + '-';
			s += prependZero(d.day) + ' ';
			s += prependZero(d.hours) + ':';
			s += prependZero(d.minutes) + ':';
			s += prependZero(d.seconds);			
			return s;
		}
		public static function getMySQLDate( date:Date ):String {
			var s:String = date.fullYear + '-';
			if( date.month < 9 ) {
				s += '0' + ( date.month + 1 ) + '-';
			} else {
				s += ( date.month + 1 ) + '-';
			}
			if( date.date < 10 ) {
				s += '0' + date.date;
			} else {
				s += date.date;
			}
			return s;
		}
		public static function getDaysBetweenDates(date1:Date,date2:Date):int
        {
        	var one_day:Number = 1000 * 60 * 60 * 24;
        	var date1_ms:Number = date1.getTime();
        	var date2_ms:Number = date2.getTime();		    
        	var difference_ms:Number = Math.abs(date1_ms - date2_ms);
        	return Math.round(difference_ms/one_day);
        }
        public static function getBeautifulDate(date:Date):String
        {
			var s:String = "";
			if( date.date < 10 ) {
				s += '0' + date.date;
			} else {
				s += date.date;
			}
			s += ".";
			if( date.month < 9 ) {
				s += '0' + ( date.month + 1 );
			} else {
				s += ( date.month + 1 );
			}
			s += ".";
			s += date.fullYear;
			return s;
        }
    }
}