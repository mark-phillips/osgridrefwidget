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

    var gridref ;
    var accuracy = "GPS: No fix";

    //! Constructor
    function initialize()
    {
        gridref = new OsGridRefUtils(null, null, 10 );
        //! Register an interest in location update events
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onLocation));

    }

    //! Handle location update events by updating position 
    function onLocation(info)
    {
      gridref = create_gridref_util(info,10);
      accuracy  = render_accuracy_screen(info) ;
      Ui.requestUpdate();
    }

    //! Handle the update event
    function onUpdate(dc)
    {
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
            dc.drawText( dc.getWidth() / 2, height_tenth*2 - dc.getFontHeight( Gfx.FONT_MEDIUM) , Gfx.FONT_MEDIUM, "OS Grid Ref" , Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText( dc.getWidth() / 2, height_tenth*5 - dc.getFontHeight( Gfx.FONT_LARGE ) , Gfx.FONT_LARGE, gridref.text , Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText( dc.getWidth() / 2, height_tenth*5 , Gfx.FONT_LARGE, location , Gfx.TEXT_JUSTIFY_CENTER);
        } else {
          if (gridref.latitude ==0 && gridref.longitude == 0) {
            dc.drawText( dc.getWidth() / 2, height_tenth*2 - dc.getFontHeight( Gfx.FONT_MEDIUM) , Gfx.FONT_MEDIUM, "OS Grid Ref" , Gfx.TEXT_JUSTIFY_CENTER);
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
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText( dc.getWidth() / 2, height_tenth*8   , Gfx.FONT_MEDIUM, accuracy, Gfx.TEXT_JUSTIFY_CENTER);


    }

    function render_accuracy_screen(info)
    {
      var accuracy = "No fix";

      if (info has :accuracy) {
        if (info.accuracy == 0) {
           accuracy = "No fix";
        }
        else if (info.accuracy == 1) {
           accuracy = "Old Fix";
        }
        else if (info.accuracy == 2)  {
           accuracy = "Poor";
        }
        else if (info.accuracy == 3)  {
           accuracy = "Usable";
        }
        else if (info.accuracy == 4)  {
           accuracy = "Good";
        }
        else  {
            accuracy = info.accuracy.toString();
        }
      }
    return "GPS " + accuracy ;
  }


    function create_gridref_util(info,precision)
    {
       var location = null;
          if (info.position has :toDegrees )
          {
            var degrees = info.position.toDegrees();
            if (degrees != null and degrees[0] != null and  degrees.size() == 2)
            {
              location =  new OsGridRefUtils(degrees[0], degrees[1], precision );
            }
          }
        if (location == null) {
          location = new OsGridRefUtils(null, null, precision );
        }
       return location;
    }

}
