package conscape.components
{
    public class Genre
	{
	    public static const ORDER:Array = [
	        "pop",
	        "black",
	        "latin",
	        "jazz",
	        "rock",
	        "metal",
	        "elektro"
	    ];
	    public static const COLOURS:Array = [
	        0xba305f,
	        0x4d3f37,
	        0xff8200,
	        0x986dda,
	        0x7bc23d,
	        0xb9c7cb,
	        0xffd400
	    ];
	    
		public function Genre()
		{
		}
		public static function getGenreObject():Object
		{
		    return {
		        "pop": {"name": "Pop", "colour": 0xba305f, "count": 0},
		        "black": {"name": "Black", "colour": 0x4d3f37, "count": 0},
		        "latin": {"name": "Latin", "colour": 0xff8200, "count": 0},
		        "jazz": {"name": "Jazz", "colour": 0x986dda, "count": 0},
		        "rock": {"name": "Rock", "colour": 0x7bc23d, "count": 0},
		        "metal": {"name": "Metal", "colour": 0xb9c7cb, "count": 0},
		        "elektro": {"name": "Elektro", "colour": 0xffd400, "count": 0}
		    };
		}
	}

}

