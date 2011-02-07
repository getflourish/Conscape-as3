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
	        0xFFFFFF,
	        0x000000,
	        0xFF0000,
	        0x0000FF,
	        0x00FFFF,
	        0x888888,
	        0xFFFF00
	    ];
	    
		public function Genre()
		{
		}
		public static function getGenreObject():Object
		{
		    return {
		        "pop": {"name": "Pop", "colour": 0xFFFFFF, "count": 0},
		        "black": {"name": "Black", "colour": 0x000000, "count": 0},
		        "latin": {"name": "Latin", "colour": 0xFF0000, "count": 0},
		        "jazz": {"name": "Jazz", "colour": 0x0000FF, "count": 0},
		        "rock": {"name": "Rock", "colour": 0x00FFFF, "count": 0},
		        "metal": {"name": "Metal", "colour": 0x888888, "count": 0},
		        "elektro": {"name": "Elektro", "colour": 0xFFFF00, "count": 0}
		    };
		}
	}

}

