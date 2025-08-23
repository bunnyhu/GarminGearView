using Toybox.System;
using Toybox.WatchUi;
using Toybox.Attention;

class MyInputDelegate extends WatchUi.InputDelegate {
    var _view;

    public function initialize(pView) {
        _view = pView;
    }

    function onTap(clickEvent) {
        _view.tapHappened();
        return true;
    }
}