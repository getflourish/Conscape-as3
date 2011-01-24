/**
 * MapProvider for Open Street Map data.
 * 
 * @author migurski
 * $Id: CloudmadeProvider.as 647 2008-08-25 23:38:15Z tom $
 */
package com.modestmaps.mapproviders
{ 
	import com.modestmaps.core.Coordinate;
	
	public class CloudmadeProvider
		extends AbstractMapProvider
		implements IMapProvider
    {
        var api_key:String;
        var style_id:Number;
        
	    public function CloudmadeProvider(minZoom:int=MIN_ZOOM, maxZoom:int=MAX_ZOOM, api_key:String = null, style_id:Number = 0)
        {
            super(minZoom, maxZoom);
            this.api_key = api_key;
            this.style_id = style_id;
        }

	    public function toString() : String
	    {
	        return "CLOUDMADE";
	    }
	
	    public function getTileUrls(coord:Coordinate):Array
	    {
	        var sourceCoord:Coordinate = sourceCoordinate(coord);
	        /*
	        String url = "http://a.tile.cloudmade.com/" + api_key + "/" + style_id + "/256/" + getZoomString(coordinate) + ".png";
            return [ 'http://a.tile.cloudmade.com/'+(sourceCoord.zoom)+'/'+(sourceCoord.column)+'/'+(sourceCoord.row)+'.png' ];
            */
	        return [ [
	            'http://a.tile.cloudmade.com',
	            this.api_key,
	            this.style_id,
	            256,
	            (sourceCoord.zoom),
	            (sourceCoord.column),
	            (sourceCoord.row)
	        ].join("/")+'.png' ];
	    }
	    
	}
}