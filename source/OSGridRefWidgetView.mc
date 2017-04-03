//!
//! Copyright 2015 by Garmin Ltd. or its subsidiaries.
//! Subject to Garmin SDK License Agreement and Wearables
//! Application Developer Agreement.
//!

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.Timer as Timer;
using Toybox.Position;

class OSGridRefWidgetView extends Ui.View
{

    var gridref;
    var debug=false;
    var accuracy = "GPS: No fix";
    var accuracy_colour = Gfx.COLOR_WHITE;
    var updateSettings = false;
    var OSGB = 1;
    var OSI = 2;
    var MGRS = 3;
    var grid_type = OSGB;
    var grid_prefix = "OS";

    //! Constructor
    function initialize()
    {
        Ui.View.initialize();
        RetrieveSettings();
        gridref = create_osgb_osi_gridref(null, null, 10 );
        //! Register an interest in location update events
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onLocation));

    }

    //! Handle location update events by updating position
    function onLocation(info)
    {
        if (debug) { System.println("location"); }
        gridref = create_gridref_util(info,10);
        accuracy  = render_accuracy_screen(info) ;
        Ui.requestUpdate();
    }

    function RetrieveSettings() {
        grid_type = Application.getApp().getProperty("COORD_TYPE");
        if (grid_type == OSGB) {
            grid_prefix = "OS";
        } else if (grid_type == OSI ){
            grid_prefix = "OSI";
        } else {
            grid_prefix = "MGRS";
        }
        if (debug) { System.println("Retrieve" + grid_type); }
    }
    //! Handle the update event
    function onUpdate(dc)
    {
        if (debug) { System.println("Update"); }
        if (updateSettings == true) {
            RetrieveSettings() ;
            updateSettings = false;
            Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onLocation));
            Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:onLocation));
            Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onLocation));
        }

        var height_tenth =  dc.getHeight() / 10;

        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();

        var location ="????";

        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(0, height_tenth*2 + dc.getFontDescent(Gfx.FONT_MEDIUM ), dc.getWidth() , 1);
        dc.fillRectangle(0, 2+height_tenth*2 + dc.getFontDescent(Gfx.FONT_MEDIUM ), dc.getWidth() , 1);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

        if (gridref.valid == true ) {
            location =  gridref.easting + " " + gridref.northing;
            dc.drawText( dc.getWidth() / 2, height_tenth*2 - dc.getFontHeight( Gfx.FONT_MEDIUM) , Gfx.FONT_MEDIUM, grid_prefix + " Grid Ref" , Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText( dc.getWidth() / 2, height_tenth*5 - dc.getFontHeight( Gfx.FONT_LARGE ) , Gfx.FONT_LARGE, gridref.text , Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText( dc.getWidth() / 2, height_tenth*5 , Gfx.FONT_LARGE, location , Gfx.TEXT_JUSTIFY_CENTER);
        } else {
          if (gridref.latitude ==0 && gridref.longitude == 0) {
            dc.drawText( dc.getWidth() / 2, height_tenth*2 - dc.getFontHeight( Gfx.FONT_MEDIUM) , Gfx.FONT_MEDIUM, grid_prefix + " Grid Ref" , Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText( dc.getWidth() / 2, height_tenth*5 - dc.getFontHeight( Gfx.FONT_LARGE ) , Gfx.FONT_LARGE, "WAITING" , Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText( dc.getWidth() / 2, height_tenth*5  , Gfx.FONT_LARGE, "FOR GPS",Gfx.TEXT_JUSTIFY_CENTER);
          }
          else {
            dc.drawText( dc.getWidth() / 2, height_tenth*2 - dc.getFontHeight( Gfx.FONT_MEDIUM), Gfx.FONT_MEDIUM, ("lat/long"), Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText( dc.getWidth() / 2, height_tenth*5 - dc.getFontHeight( Gfx.FONT_LARGE ) , Gfx.FONT_LARGE, ("lat:" + gridref.latitude), Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText( dc.getWidth() / 2, height_tenth*5  , Gfx.FONT_LARGE, ("lon:" + gridref.longitude), Gfx.TEXT_JUSTIFY_CENTER);
          }
        }

        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(0, height_tenth*8-4 , dc.getWidth() , 1);
        dc.fillRectangle(0, height_tenth*8-2 , dc.getWidth() , 1);
        dc.setColor(accuracy_colour, Gfx.COLOR_TRANSPARENT);
        dc.drawText( dc.getWidth() / 2, height_tenth*8   , Gfx.FONT_MEDIUM, accuracy, Gfx.TEXT_JUSTIFY_CENTER);


    }

    function render_accuracy_screen(info)
    {
        var accuracy_text = ["No fix", "Old Fix", "Poor", "Usable", "Good"];
        var accuracy = accuracy_text[0];

        if (info has :accuracy) {
            if (info.accuracy >0 && info.accuracy < 5) {
              accuracy = accuracy_text[info.accuracy];
            }
            else {
              accuracy = info.accuracy.toString();
            }
        }
        return "GPS " + accuracy ;
    }


    function create_gridref_util(info,precision)
    {
        var grid_ref = null;
        if (grid_type == MGRS) {
            grid_ref = new OSGridRef(null,null,10);
            var mgrs_gridref = info.position.toGeoString(Toybox.Position.GEO_MGRS);
            grid_ref.valid = true;
            grid_ref.text = mgrs_gridref.substring( 0, 6);
            grid_ref.easting = mgrs_gridref.substring( 7, 12);
            grid_ref.northing = mgrs_gridref.substring( 12, 17);

            if (debug) { System.println("mgrs" + mgrs_gridref); }
        }
        else {

            if (info.position has :toDegrees )
            {
                var degrees = info.position.toDegrees();
                if (debug) { System.println("position: " + degrees); }
                if (degrees != null and degrees[0] != null and  degrees.size() == 2)
                {
                    grid_ref =  create_osgb_osi_gridref(degrees[0], degrees[1], precision );
                }
            }
        }
        if (grid_ref == null) {
            grid_ref =  create_osgb_osi_gridref(null,null,6);
        }
       return grid_ref;
    }

    function create_osgb_osi_gridref(lat,lon,precision) {
//        if (debug) { lat =  53.34979538; lon = -6.2602533;}  // Spire of Dublin
        if (grid_type == OSGB) {
            return new OSGridRef(lat,lon, precision );
        } else {
            return new IrishGridRef(lat,lon, precision );
        }
    }
}
