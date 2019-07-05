using Toybox.Application;

class StockWidgetApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new StockWidgetView() ];
    }

	function onSettingsChanged() {
        System.println("onSettingsUpdate");
        WatchUi.requestUpdate();
    }
    
}