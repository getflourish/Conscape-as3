package conscape.components
{
    import flash.utils.Dictionary;
    
	public class Genre
	{
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
		        "rock": {"name": "Rock", "colour": 0xFF00FF, "count": 0},
		        "metal": {"name": "Metal", "colour": 0x888888, "count": 0},
		        "elektro": {"name": "Elektro", "colour": 0xFFFF00, "count": 0}
		    };
		}
	}

}

