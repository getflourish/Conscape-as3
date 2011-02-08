package conscape.util
{
	/**
	 * Utility methods for working with arrays.
	 */
	public class Arrays
	{
		public static const EMPTY:Array = new Array(0);
		
		/**
		 * Constructor, throws an error if called, as this is an abstract class.
		 */
		public function Arrays() {
			throw new ArgumentError("This is an abstract class.");
		}

		public static function copy(a:Array, b:Array=null, a0:int=0, b0:int=0, len:int=-1) : Array {
			len = (len < 0 ? a.length : len);
			if (b==null) {
				b = new Array(b0+len);
			} else {
				while (b.length < b0+len) b.push(null);
			}

			for (var i:uint = 0; i<len; ++i) {
				b[b0+i] = a[a0+i];
			}
			return b;
		}

	} // end of class Arrays
}