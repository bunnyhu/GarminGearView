import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.FitContributor;

/*!
    Bunny's datafield for Garmin Edge
    GEAR VIEW

    @author Karoly Szabo (Bunny)
    @version 1.0
    @link https://github.com/bunnyhu/GarminGearView
*/
class GarminAppView extends WatchUi.DataField {

    public var _deviceName as String = "";
    //! Active layout (2x2, 2x1, 1x1)
    public var _layout as String = "wrongLayout";

    //! Active layout changed by tapping
    public var _layoutChanged as Boolean = true;

    //! Edge in dark mode?
    public var _darkMode as Boolean = false;

    //! m/s multiplier for speed (km/h or mi/h)
    public var _speedMod as Float = 1.0;

    //! Text Align class
    public var _padding as Align = new Align();

    //! GearCalculator class
    public var _gears as GearCalculator = new GearCalculator();

    //! Active bike index (from properties)
    public var activeBikeIndex as Number = 0;

    //! Are we logging the gears to the activity? (from properties)
    public var needLogGears as Boolean = false;

    //!
    public var tapEventIndex as Number = 1;

    //! When get the best gears last time
    public var lastGearTime = null;

    //! Last valid best ratios
    public var _lastBestRatios as Array = [];

    //! FitContributor.Field for gear graph
    public var _fitGears = null;

    //! FitContributor.Field for ratio graph
    public var _fitRatio = null;

    //! Gear style
    //!
    //! | 1 - chainring and cassette cog
    //! | 2 - chainring index and cassette cog
    //! | 3 - chainring and cassette index
    //! | 4 - combined total speed gear
    //! | 5 - graphics visualization
    public var gearStyle as Number = 1;

    //! All bikes information [bikeConfig, ...]
    public var bikes as Array = [];

    //! Current activity informations
    public var currentInfo as Dictionary = {
        :speed => 0.0,
        :cadence => 0,
    };

    //! best ratio for all chainring if inside the tolerance
    var bestRatios;

    //! only the best ratio
    var bestRatio;

    // Explore 2 layout FONTS, for other devices fillAlignArray()

    //! One number layer alignable labels
    public var _alignableSpeedgear as Array = [
        ["label", Graphics.FONT_TINY ],
        ["gear0", Graphics.FONT_NUMBER_HOT],
    ];

    //! GFX layer
    public var _alignable5 as Array = [
        ["label", Graphics.FONT_TINY ],
    ];

    //! 1 chainring layer alignable labels
    public var _alignable1 as Array = [
        ["label", Graphics.FONT_TINY ],
        ["cr0", Graphics.FONT_LARGE],
        ["gear0", Graphics.FONT_NUMBER_MEDIUM],
    ];

    //! 2 chainring layer alignable labels
    public var _alignable2 as Array = [
        ["label", Graphics.FONT_TINY ],
        ["cr0", Graphics.FONT_LARGE],
        ["cr1", Graphics.FONT_LARGE],
        ["gear0", Graphics.FONT_NUMBER_MEDIUM],
        ["gear1", Graphics.FONT_NUMBER_MEDIUM],
    ];

    //! 3 chainring layer alignable labels
    public var _alignable3 as Array = [
        ["label", Graphics.FONT_TINY ],
        ["cr0", Graphics.FONT_MEDIUM],
        ["cr1", Graphics.FONT_MEDIUM],
        ["cr2", Graphics.FONT_MEDIUM],
        ["gear0", Graphics.FONT_LARGE],
        ["gear1", Graphics.FONT_LARGE],
        ["gear2", Graphics.FONT_LARGE],
    ];


    //! Device based FONT align array corretion
    public function fillAlignArray() as Void {
        if (_deviceName.equals("edge540") || _deviceName.equals("edge840") || _deviceName.equals("edgemtb")) {
            _alignable1 = [
                ["label", Graphics.FONT_TINY ],
                ["cr0", Graphics.FONT_MEDIUM],
                ["gear0", Graphics.FONT_LARGE],
            ];
            _alignable2 = [
                ["label", Graphics.FONT_TINY ],
                ["cr0", Graphics.FONT_MEDIUM],
                ["cr1", Graphics.FONT_MEDIUM],
                ["gear0", Graphics.FONT_LARGE],
                ["gear1", Graphics.FONT_LARGE],
            ];
        }
        if (_deviceName.equals("edge1040") || _deviceName.equals("edge1050")) {
            _alignable3  = [
                ["label", Graphics.FONT_TINY ],
                ["cr0", Graphics.FONT_LARGE],
                ["cr1", Graphics.FONT_LARGE],
                ["cr2", Graphics.FONT_LARGE],
                ["gear0", Graphics.FONT_LARGE],
                ["gear1", Graphics.FONT_LARGE],
                ["gear2", Graphics.FONT_LARGE],
            ];
        }
    }


    //! *************************************
    function initialize() {
        DataField.initialize();
        if ( System.getDeviceSettings().distanceUnits == System.UNIT_METRIC) {
            _speedMod = 3.6;
        } else {
            _speedMod = 2.23694;
        }
        _deviceName = WatchUi.loadResource(Rez.Strings.device);
        getConfigFromProperties();
        fillAlignArray();
        if (needLogGears) {
            _fitGears = createField(
                "cogs",
                0, FitContributor.DATA_TYPE_UINT32,
                {
                    :mesgType => FitContributor.MESG_TYPE_RECORD,
                    :units => WatchUi.loadResource(Rez.Strings.fitUnitLabel0).toString(),
                }
            );
            _fitRatio = createField(
                "ratios",
                1, FitContributor.DATA_TYPE_FLOAT,
                {
                    :mesgType => FitContributor.MESG_TYPE_RECORD,
                }
            );
            _fitGears.setData(0);
            _fitRatio.setData(0.0);
        }
    }


    //! *************************************
    function onLayout(dc as Dc) as Void {
        var screenWidth = System.getDeviceSettings().screenWidth;
        var screenHeight = System.getDeviceSettings().screenHeight;
        var fieldWidth = dc.getWidth();
        var fieldHeight = dc.getHeight();

        if (fieldWidth >= (screenWidth/2) ) {
            if (fieldHeight>=(screenHeight/2)) {
                _layout="2x2";
            } else if (fieldHeight>=(screenHeight/4)) {
                _layout="2x2";
            } else {
                _layout="2x1";
            }
        } else {
            _layout="1x1";
        }
        setActiveLayout(dc);
    }


    //! *************************************
    function compute(info as Activity.Info) as Void {
        if ((info has :currentSpeed) && (info.currentSpeed != null)) {
            currentInfo[:speed] = info.currentSpeed;
        }
        if ((info has :currentCadence) && (info.currentCadence != null)) {
            currentInfo[:cadence] = info.currentCadence;
        }

        // currentInfo[:speed] = 25/3.6;
        // currentInfo[:cadence] = 73;

        bestRatios = _gears.getAllBestRatio(currentInfo[:speed], currentInfo[:cadence]);
        if (bestRatios.size() > 0) {
            _lastBestRatios = bestRatios;
            lastGearTime = Time.now();
        } else {
            bestRatios = _lastBestRatios;
        }

        bestRatio = {};
        for (var f=0; f<bestRatios.size();f++) {
            if (bestRatio.isEmpty()) {
                bestRatio = bestRatios[f];
            } else if (bestRatios[f][:spdiff] < bestRatio[:spdiff]) {
                bestRatio = bestRatios[f];
            }
        }

        if (!bestRatio.isEmpty() && needLogGears) {
            if ( _fitGears != null ) {
                var gString = _gears.getGearsSpeedIndex( bestRatio[:front], bestRatio[:rear]).format("%02d") +
                    bestRatio[:front].format("%03d") + bestRatio[:rear].format("%03d");
                _fitGears.setData( gString.toNumber());
                System.print(gString + " - ");
                System.println(gString.toNumber());
            }
            if ( _fitRatio != null) {
                _fitRatio.setData( bestRatio[:ratio] );
            }
        }
    }


    //! *************************************
    function onUpdate(dc as Dc) as Void {
        var numColor;
        var lightColor;
        var labelColor;

        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            _darkMode = true;
            numColor = Graphics.COLOR_WHITE;
            lightColor = Graphics.COLOR_DK_GRAY;
            labelColor = Graphics.COLOR_LT_GRAY;
        } else {
            _darkMode = false;
            numColor = Graphics.COLOR_BLACK;
            lightColor = Graphics.COLOR_LT_GRAY;
            labelColor = Graphics.COLOR_DK_GRAY;
        }

        if (_layoutChanged) {
            setActiveLayout(dc);
        }

        setDrawableColor("Background", getBackgroundColor());
        setDrawableColor("label", labelColor);
        setDrawableText("label", bikes[activeBikeIndex][:name] );

        if (! _layout.equals( "1x1" )) {
            View.onUpdate(dc);
            return;
        }

        setDrawableColor("cr0", lightColor);
        setDrawableColor("cr1", lightColor);
        setDrawableColor("cr2", lightColor);
        setDrawableColor("gear0", lightColor);
        setDrawableColor("gear1", lightColor);
        setDrawableColor("gear2", lightColor);

        if (Activity.getActivityInfo().timerState != 3) {
            setDrawableText("cr0", "-");
            setDrawableText("cr1", "-");
            setDrawableText("cr2", "-");
            setDrawableText("gear0", "-");
            setDrawableText("gear1", "-");
            setDrawableText("gear2", "-");
            View.onUpdate(dc);
            return;
        }

        if (gearStyle == 4) {
            setDrawableColor("gear0", numColor);
            setDrawableText("gear0", _gears.getGearsSpeedIndex( bestRatio[:front], bestRatio[:rear]).toString());
        } else if (gearStyle == 5) {
            if ((View.findDrawableById("graphGears") as GfxGears) != null) {
                (View.findDrawableById("graphGears") as GfxGears).setCurrents({
                    :bests => bestRatios,
                    :best => bestRatio,
                    :darkMode => _darkMode,
                });
            }
        } else {
            var frontStyleCog = true;
            var rearStyleCog = true;

            if (gearStyle == 2) {
                frontStyleCog = false;
            } else if (gearStyle == 3) {
                frontStyleCog = false;
                rearStyleCog = false;
            }
            for (var f=0; f<_gears.frontGears.size(); f++) {
                setDrawableText("cr"+f.toString(), "");
                setDrawableText("gear"+f.toString(), "");
                for (var r=0; r<bestRatios.size(); r++) {
                    var currentRearGear = 0;
                    if (( bestRatios[r] != null ) && (bestRatios[r].size() >= 4) && ( bestRatios[r][:ratio] > 0)) {
                        if (bestRatios[r][:front] == _gears.frontGears[f]) {
                            currentRearGear = bestRatios[r][:rear];
                            if (bestRatio[:front] == _gears.frontGears[f]) {
                                setDrawableColor("cr"+f.toString(), numColor);
                                setDrawableColor("gear"+f.toString(), numColor);
                            }
                            if (frontStyleCog) {
                                setDrawableText("cr"+f.toString(), _gears.frontGears[f].toString());
                            } else {
                                setDrawableText("cr"+f.toString(), (_gears.frontGears.indexOf( _gears.frontGears[f]) +1).toString());
                            }
                            if (rearStyleCog) {
                                setDrawableText("gear"+f.toString(), currentRearGear.toString());
                            } else {
                                setDrawableText("gear"+f.toString(), (_gears.rearGears.indexOf(currentRearGear) +1).toString());
                            }
                        }
                    }
                }
            }
        }
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }


    //! Active layout setter
    public function setActiveLayout(dc as Dc) as Void {
        if (_layout.equals( "1x1" ) ) {
            if (gearStyle == 4) {
                View.setLayout(Rez.Layouts.speedgear(dc));
                for (var f=0; f<_alignableSpeedgear.size(); f++) {
                    _padding.reAlignWithFont( View.findDrawableById(_alignableSpeedgear[f][0]) as Text, _alignableSpeedgear[f][1]);
                }
            } else if (gearStyle == 5) {
                View.setLayout(Rez.Layouts.graph1(dc));
                for (var f=0; f<_alignable5.size(); f++) {
                    _padding.reAlignWithFont( View.findDrawableById(_alignable5[f][0]) as Text, _alignable5[f][1]);
                }
                (View.findDrawableById("graphGears") as GfxGears).setOptions({
                    :front => _gears.frontGears,
                    :rear => _gears.rearGears,
                });
            } else {
                switch (_gears.frontGears.size()) {
                    case 1:
                        View.setLayout(Rez.Layouts.chainrings1(dc));
                        for (var f=0; f<_alignable1.size(); f++) {
                            _padding.reAlignWithFont( View.findDrawableById(_alignable1[f][0]) as Text, _alignable1[f][1]);
                        }
                        break;
                    case 2:
                        View.setLayout(Rez.Layouts.chainrings2(dc));
                        for (var f=0; f<_alignable2.size(); f++) {
                            _padding.reAlignWithFont( View.findDrawableById(_alignable2[f][0]) as Text, _alignable2[f][1]);
                        }
                        break;
                    default:
                        View.setLayout(Rez.Layouts.chainrings3(dc));
                        for (var f=0; f<_alignable3.size(); f++) {
                            _padding.reAlignWithFont( View.findDrawableById(_alignable3[f][0]) as Text, _alignable3[f][1]);
                        }
                        break;
                }
            }
        } else {
            View.setLayout(Rez.Layouts.wrongLayout(dc));
        }
        _layoutChanged = false;
    }


    //! Safe setText(), set only if the id is valid
    function setDrawableText(pId, pValue as String or ResourceId) {
        var elem = View.findDrawableById(pId) as Text;
        if (elem != null) {
            elem.setText(pValue);
        }
    }


    //! Safe setColor(), set only if the id is valid
    function setDrawableColor(pId, pValue as Graphics.ColorType) {
        var elem = View.findDrawableById(pId) as Text;
        if (elem != null) {
            elem.setColor(pValue);
        }
    }


    //! Load Properties config settings
    public function getConfigFromProperties() as Void {
        // {
        //     :name => "gravel",
        //     :frontGears => "46,30",
        //     :rearGears => "12,11,15,14,13,17,19,24,21,27,34,30",
        //     :wheel_mm => 2151,
        // };

        // System.println( StringHelper.getValidString("12av,11..AA,15,14,13,17,19,24,21,27,34,30:", StringHelper.VALID_NUMS+",", null) );
        activeBikeIndex = Application.Properties.getValue("activeBikeIndex").toNumber() - 1;
        if ((activeBikeIndex < 0) || (activeBikeIndex == null)) {
            activeBikeIndex = 0;
        }
        gearStyle = Application.Properties.getValue("gearStyle").toNumber();
        needLogGears = Application.Properties.getValue("logging");
        tapEventIndex = Application.Properties.getValue("tapping").toNumber();

        bikes = [];
        for (var b=1; b<10; b++) {
            bikes.add( getBikeFromProperty(Application.Properties.getValue("bike"+b.toString())) );
        }
        _gears.load(
            bikes[activeBikeIndex][:frontGears],
            bikes[activeBikeIndex][:rearGears],
            bikes[activeBikeIndex][:wheel_mm]
        );
        if ( _gears.isValid() == false ) {
            System.println("invalid gear datas");
        }
    }


    //! Tapped on the datafield
    public function tapHappened() {
        if (tapEventIndex <= 1) {
            return;
        }
        switch (tapEventIndex) {
            case 2:
                // Layout
                var gs = Application.Properties.getValue("gearStyle").toNumber();
                gs += 1;
                if (gs > 5) { gs = 1; }
                Application.Properties.setValue("gearStyle", gs);
                _layoutChanged = true;
                break;
            case 3:
                // Bike
                var maxBike = 8;
                var b = Application.Properties.getValue("activeBikeIndex").toNumber()-1;
                for (var f=0; f < maxBike; f++) {
                    b += 1;
                    if (b > maxBike) { b = 0; }
                    if (bikes[b][:rearGears].toString().length() > 0) {
                        Application.Properties.setValue("activeBikeIndex", b+1);
                        break;
                    }
                }
                break;
        }
        getConfigFromProperties();
        if (Attention has :playTone) {
            Attention.playTone(Attention.TONE_LOUD_BEEP);
        }
    }


    //! Read one bike settings string from properties
    //! @return bikeConfig format {name wheel_mm frontGears rearGears}
    private function getBikeFromProperty( bikeSettings as String) as Dictionary {
        var result = {
            :name => "",
            :wheel_mm => 0,         // wheel circumferences in mm
            :frontGears => "",
            :rearGears => "",
        };
        try {
            if (bikeSettings.length() == null) {
                return result;
            }
            var bikeArray = StringHelper.strExplode( bikeSettings, ":" );
            if (bikeArray.size() != 4) {
                return result;
            }
            if (
                StringHelper.strValidator(bikeArray[1], StringHelper.VALID_NUMS, -1) == false or
                StringHelper.strValidator(bikeArray[2], StringHelper.VALID_NUMS+",", -1) == false or
                StringHelper.strValidator(bikeArray[3], StringHelper.VALID_NUMS+",", -1) == false

            ) {
                return result;
            }
            result[:name] = StringHelper.strTrim(bikeArray[0].toString());
            result[:wheel_mm] = bikeArray[1].toNumber();
            result[:frontGears] = bikeArray[2];
            result[:rearGears] = bikeArray[3];

            if (result[:name].toString().length() > 16) {
                result[:name] = result[:name].toString().substring(0, 16);
            }
        } catch (ex) {
            return {
                :name => "",
                :wheel_mm => 0,         // wheel circumferences in mm
                :frontGears => "",
                :rearGears => "",
            };
        }
        return result;
    }
}
