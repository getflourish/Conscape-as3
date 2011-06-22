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
	        "elektro",
	        "andere"
	    ];
	    public static const COLOURS:Array = [
	        0xba305f,
	        0x4d3f37,
	        0xff8200,
	        0x986dda,
	        0xFF0000,
	        0xb9c7cb,
	        0xffd400,
	        0x7bc23d
	    ];
	    public static const NAMES:Array = [
	        "Pop",
	        "Black",
	        "Latin",
	        "Jazz",
	        "Rock",
	        "Metal",
	        "Elektro",
	        "Andere"
	    ];
	    
		public function Genre()
		{
		}
		public static function getGenreObject():Object
		{
		    var genres:Object = {};
		    for (var i:Number = 0; i < Genre.ORDER.length; i++) {
		        genres[Genre.ORDER[i]] = {
		            "id": Genre.ORDER[i],
		            "name": Genre.NAMES[i],
		            "colour": Genre.COLOURS[i],
		            "count": 0
		        };
		    }
		    return genres;
		}
		public static function getGenre(id:String):Object
		{
		    return Genre.getGenreObject()[id];
		}
	}

}

