import Toybox.Lang;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.UserProfile;

/*!
    Datafield background color drawable
*/
class Background extends WatchUi.Drawable {
    hidden var mColor as ColorValue;

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };
        Drawable.initialize(dictionary);
        mColor = Graphics.COLOR_WHITE;
    }


    function setColor(color as ColorValue) as Void {
        mColor = color;
    }


    function draw(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_TRANSPARENT, mColor);
        dc.clear();
    }
}


//! Visual gears class
class GfxGears extends WatchUi.Drawable {
    private var _align = new Align();
    private var _fontSizes;

    public var frontGears = [];
    public var rearGears = [];
    public var bestRatios = [];
    public var bestRatio = [];
    public var barWidth = 0;
    public var barHeight = 0.0f;
    public var colorIndex = 0;
    public var colors = [
        {
            // daylight mode
            :c1 => Graphics.COLOR_BLACK,    // best bar
            :c2 => Graphics.COLOR_LT_GRAY,  // alternative bar
            :c3 => Graphics.COLOR_WHITE,    // front gear font
            :c4 => Graphics.COLOR_DK_GRAY,  // bar border
        },
        {
            // night mode
            :c1 => Graphics.COLOR_WHITE,
            :c2 => Graphics.COLOR_DK_GRAY,
            :c3 => Graphics.COLOR_BLACK,
            :c4 => Graphics.COLOR_LT_GRAY,
        }
    ];


    function initialize(options) {
        Drawable.initialize(options);
        _fontSizes = WatchUi.loadResource(Rez.JsonData.fontSizes);
        setOptions(options);
    }


    //! Set the gears
    //!
    //! ( :front :rear )
    public function setOptions(param as Dictionary) as Void {
        if (param[:front] != null) {
            frontGears = param[:front];
        }
        if (param[:rear] != null) {
            rearGears = param[:rear];
        }
        barSizeCalc();
    }


    //! Set the current gear and other informations
    //!
    //! ( :bests :best :darkMode )
    public function setCurrents(param as Dictionary) as Void {
        if (param[:bests] != null) {
            bestRatios = param[:bests];
        }
        if (param[:best] != null) {
            bestRatio = param[:best];
        }
        if (param[:darkMode] != null) {
            colorIndex = (param[:darkMode]) ? 1 : 0;
        }
    }


    //! Calculate one gear bar width and height and set to Class variable
    //! Also set the locX for center the bars
    public function barSizeCalc() {
        if ((rearGears != null) && (rearGears.size()>0)) {
            var diff = rearGears[0] - rearGears[rearGears.size()-1];
            barHeight = (height.toFloat() / rearGears[0].toFloat()) as Float;
            barWidth = Math.floor((width.toFloat() / rearGears.size().toFloat()) as Float)+1;
            var locXnew = Math.floor((width-((barWidth-1)*rearGears.size())) / 2);
            if (locXnew>0) {
                locX = locX + locXnew;  // make it center
            }
        }
    }


    public function draw(dc as Dc) as Void {
        //! Next Bar X
        var cursorX = locX;

        //! Bar bottom Y aka baseline
        var cursorY = locY + height;

        //! front gear font style
        var font = Graphics.FONT_MEDIUM;

        //! aligned front gear font Y
        var fontY = _align.reAlignY(cursorY-_fontSizes[font], font);

        dc.setPenWidth(1);
        for (var f=0; f<rearGears.size(); f++) {
            // Bar height based on gear number
            var bh = Math.round((barHeight * rearGears[f].toFloat()));
            if ((bestRatio.size()>0) && (rearGears[f]==bestRatio[:rear])) {
                // The best possible ratio
                dc.setColor(colors[colorIndex][:c1], Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle (cursorX, cursorY - bh, barWidth, bh);
                dc.setColor(colors[colorIndex][:c3], Graphics.COLOR_TRANSPARENT);
                dc.drawText( cursorX+(Math.floor(barWidth/2)), fontY , font, frontGears.indexOf(bestRatio[:front])+1, Graphics.TEXT_JUSTIFY_CENTER);
            } else if (findRear(rearGears[f])>0) {
                // Possible selected ration
                dc.setColor(colors[colorIndex][:c2], Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle (cursorX, cursorY - bh, barWidth, bh);
                dc.setColor(colors[colorIndex][:c1], Graphics.COLOR_TRANSPARENT);
                dc.drawText( cursorX+(Math.floor(barWidth/2)), fontY, font, frontGears.indexOf(findRear(rearGears[f]))+1, Graphics.TEXT_JUSTIFY_CENTER);
            } else {
                // Empty bar
                dc.setColor(colors[colorIndex][:c4], Graphics.COLOR_WHITE);
                dc.drawRectangle(cursorX, cursorY - bh, barWidth, bh);
            }

            cursorX += barWidth-1;
        }
    }


    //! Check the rear gear if it is a selected list (member of bestRatios).
    //! @return front gear cog number or -1 if not found
    public function findRear(pRear as Number) as Number {
        if (bestRatios.size() > 0) {
            for (var f=0; f<bestRatios.size();f++) {
                if (bestRatios[f][:rear] == pRear) {
                    return bestRatios[f][:front];
                }
            }
        }
        return -1;
    }
}