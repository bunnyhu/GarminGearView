import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class GarminApp extends Application.AppBase {

    public var _view;

    function initialize() {
        AppBase.initialize();
        _view = new GarminAppView();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    //! Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ _view, new MyInputDelegate(_view) ];
    }

    function onSettingsChanged() as Void {
        System.println("Setting changed");
        _view.getConfigFromProperties();
    }

}

function getApp() as GarminApp {
    return Application.getApp() as GarminApp;
}