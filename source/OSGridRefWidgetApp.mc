//!
//! Copyright 2015 by Garmin Ltd. or its subsidiaries.
//! Subject to Garmin SDK License Agreement and Wearables
//! Application Developer Agreement.
//!

using Toybox.Application as App;

//! this is the primary start point for a ConnectIQ application
class OSGridRefWidget extends App.AppBase
{
    var view = null;

    function initialize() {
        AppBase.initialize();
    }

    function onSettingsChanged() {
      if (view != null) {
        view.updateSettings = true;
        Toybox.WatchUi.requestUpdate();

      }
    }
    function onStart(state)
    {
        return false;
    }

    function getInitialView()
    {
        view = new OSGridRefWidgetView() ;
        return [view];
    }

    function onStop(state)
    {
        return false;
    }
}
