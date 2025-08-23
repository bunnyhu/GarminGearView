import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

/*!
    Compensate the simulator and the device padding difference in the built in fonts
    DO NOT USE WITH PIXEL FONTS!

    change excludeAnnotations in monkey.jungle: s for device, d for simulator
    make resources:  Rez.JsonData.DeviceFontPaddings  ;  Rez.JsonData.SimulatorFontPaddings

    @link https://github.com/maca88/E-Bike-Edge-MultiField/tree/master/Source/FontPaddings
*/

//! Font padding for precise position on real device / simulator
class Align {
    public var paddings;
    public var font = Graphics.FONT_SMALL; // SYSTEM fonts need -9 !!!

    function initialize() {
        paddings = getPaddings();
    }

    //! Font padding for device
    (:d)
    private function getPaddings() {
        // System.println("Loading device font paddings");
        return WatchUi.loadResource(Rez.JsonData.DeviceFontPaddings);
    }

    //! Font padding for simulator
    (:s)
    private function getPaddings() {
        // System.println("Loading simulator font paddings");
        return WatchUi.loadResource(Rez.JsonData.SimulatorFontPaddings);
    }

    //! Text Y padding realign with font
    function reAlignWithFont(item as Text, _font as Number) {
        if (item != null) {
            item.locY = item.locY - paddings[_font];
        }
    }

    //! Text Y padding realign with default font
    function reAlign(item as Text) {
        if (item != null) {
            item.locY = item.locY - paddings[font];
        }
    }

    //! Y padding realign
    function reAlignY(y as Number, font as Number) as Number {
        return y - paddings[font];
    }
}