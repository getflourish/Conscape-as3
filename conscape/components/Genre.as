package conscape.components
{
    public class Genre
	{
	    public static const ORDER:Array = [
	        "-1",
	        "0",
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "11",
            "12",
            "13",
            "14",
            "15",
            "16",
            "17",
            "18",
            "19",
            "20",
            "21",
            "22",
            "23"
	    ];
	    public static const COLOURS:Array = [
	        0x7bc23d,
	        0x7bc23d,
            0x7bc23d,
            0x7bc23d,
            0x7bc23d,
            0x7bc23d,
            0x7bc23d,
            0x7bc23d,
            0xffd400,
            0x7bc23d,
            0x7bc23d,
            0x986dda,
            0xff8200,
            0x7bc23d,
            0x7bc23d,
            0xFF0000,
            0xb9c7cb,
            0xba305f,
            0x4d3f37,
            0x7bc23d,
            0x7bc23d,
            0x7bc23d,
            0x7bc23d,
            0x7bc23d,
	    ];
	    public static const NAMES:Array = [
	        "Andere",
	        "Avant-Garde",
            "Blues",
            "Childrens",
            "Classical",
            "Comedy/Spoken",
            "Country",
            "Easy Listening",
            "Electro",
            "Folk",
            "Holiday",
            "Jazz",
            "Latin",
            "New Age",
            "Alternative/Indie",
            "Rock",
            "Metal",
            "Pop",
            "R&B",
            "Rap",
            "Reggae",
            "Religious",
            "Stage & Screen",
            "Vocal"
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

