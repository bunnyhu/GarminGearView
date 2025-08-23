import Toybox.System;
import Toybox.Lang;

//! Gear calculator
//!
//! GearCalculator(pFront as String, pRear as String, pWheel as Number)
//!
//! pFront and pRear gear separate with comma (,)
class GearCalculator {
    //! array of front gears (chainrings) from smallest to largest
    public var frontGears as Array = [];

    //! array of rear gears (cassette) from smallest to largest
    public var rearGears as Array = [];

    //! wheel circumference in meter
    public var wheelC as Float = 0.0;

    //! array of gears ratios {ratio, front, rear, spdiff}, ..
    public var ratios as Array = [];

    //! array of gears ratios by chainrings [{ratio, front, rear, spdiff}, ..], ...
    public var ratiosPerRings as Array = [];

    //! max tolerance for the best gear speed in m/s (~0.7 km/h)
    public var tolerance_ms = 0.2;

    //! A few tipical tire ETRTO size diameter in mm
    // private const tireSize as Array = [
    //      [935, "47-203"],  [940, "54-203"], [1020, "40-254"], [1055, "47-254"], [1185, "40-305"], [1195, "47-305"],
    //     [1245, "54-305"], [1290, "28-349"], [1300, "37-349"], [1340, "32-369"], [1340, "40-355"], [1350, "47-355"],
    //     [1450, "32-406"], [1460, "35-406"], [1490, "40-406"], [1515, "47-406"], [1565, "50-406"], [1545, "28-451"],
    //     [1615, "37-451"], [1770, "37-501"], [1785, "40-501"], [1890, "47-507"], [1925, "50-507"], [1965, "54-507"],
    //     [1753, "25-520"], [1795, "28-540"], [1905, "32-540"], [1913, "25-559"], [1950, "32-559"], [2005, "37-559"],
    //     [2010, "40-559"], [2023, "47-559"], [2050, "50-559"], [2068, "54-559"], [2070, "57-559"], [2083, "58-559"],
    //     [2170, "75-559"], [1970, "28-590"], [2068, "37-590"], [2100, "37-584"], [1938, "20-571"], [1944, "23-571"],
    //     [1952, "25-571"], [2125, "40-590"], [2105, "40-584"], [2145, "25-630"], [2155, "28-630"], [2161, "32-630"],
    //     [2169, "37-630"], [2079, "40-584"], [2090, "50-584"], [2148, "54-584"], [2182, "57-584"],
    //     [2070, "18-622"], [2080, "19-622"], [2086, "20-622"], [2096, "23-622"], [2105, "25-622"], [2136, "28-622"],
    //     [2146, "30-622"], [2155, "32-622"], [2168, "35-622"], [2180, "38-622"], [2200, "40-622"], [2224, "42-622"],
    //     [2235, "44-622"], [2242, "45-622"], [2268, "47-622"], [2288, "54-622"], [2298, "56-622"], [2326, "60-622"]
    // ];


    //! Load the gear and wheel information at the start procedure
    //!
    //! pFront and pRear gear separate with comma (,)
    public function load(pFront as String, pRear as String, pWheel as Number) as Void {
        if (pWheel != null) {
            wheelC = pWheel.toFloat() / 1000;
        }
        if ((pFront != null) && (pFront.length() > 0) ) {
            frontGears = [];
            var g = StringHelper.strExplode(pFront, ",");
            for (var f=0; f<g.size(); f++) {
                frontGears.add( g[f].toNumber() );
            }
            frontGears.sort(null);
        }
        if ((pRear != null) && (pRear.length() > 0) ) {
            rearGears = [];
            var g = StringHelper.strExplode(pRear, ",");
            for (var f=0; f<g.size(); f++) {
                rearGears.add( g[f].toNumber() );
            }
            rearGears.sort(new rearGearComparator() as Lang.Comparator);
        }
        fillRatiosArray(frontGears, rearGears);
        // System.println(ratios);
    }


    //! Fill the ratios and ratiosPerRings array {ratio, front, rear, spdiff}
    public function fillRatiosArray(frontArray, rearArray) {
        ratiosPerRings = [];
        ratios = [];

        for (var f = 0; f < frontArray.size(); f++) {
            var result = [];

            for (var r = 0; r < rearArray.size(); r++) {
                result.add({
                    :ratio => (frontArray[f].toFloat() / rearArray[r].toFloat()).toFloat(),
                    :front => frontArray[f] as Number,
                    :rear => rearArray[r] as Number,
                    :spdiff => 0.0f,
                });
            }
            ratiosPerRings.add(result);
            ratios = ratios.addAll(result);
        }
        ratios.sort(new RatiosComparatorAsc() as Lang.Comparator);
        // System.println(ratios);
    }


    //! Find the best ratio for the actual speed+cadence
    public function getBestRatio(speed as Float, cadence as Number) as Array {
        return _findBestRatio(speed, cadence, ratios);
    }


    //! Find the best ratio for every chainring, but only if that is in the tolerance
    //! @return array of [ratio, frontGear, rearGear, speedDiff_ms] for all possible chainring
    public function getAllBestRatio(speed as Float, cadence as Number) as Array {
        var result = [];
        for (var f = 0; f < ratiosPerRings.size(); f++) {
            var bestRatio = _findBestRatio(speed, cadence, ratiosPerRings[f]);
            // System.println(bestRatio);
            if ( bestRatio[:spdiff] <= tolerance_ms ) {
                result.add( bestRatio );
            }
        }
        return result;
    }


    //! Get the speed in m/s for the ratio
    public function getRatioSpeed( ratio as Float, cadence as Number) as Float {
        return ( cadence * ratio ) * ( wheelC / 60 );
    }


    //! Find the best ratio in the given ratios array
    //! @param ratios Array of ratios arrays
    //! @return best ratio's Array [ratio, frontGear, rearGear, speedDiff_ms]
    private function _findBestRatio(speed as Float, cadence as Number, ratios as Array) as Array {
        //! speed different between actual speed and BEST ratio calculated speed
        var bestSpeedDiff = 9999.9999;
        //! gear ratio
        var ratio = 0.0;
        //!  actual gear speed diff in ms
        var ratioSpeedDiff = 0.0;
        //! best ratio array, the final will be the return
        var bestRatio = [];

        for (var f=0; f < ratios.size(); f++) {
            ratio = ratios[f][:ratio];
            ratioSpeedDiff = getRatioSpeed(ratio, cadence);
            ratioSpeedDiff = (speed - getRatioSpeed(ratio, cadence)).abs();
            if (ratioSpeedDiff < bestSpeedDiff) {
                bestSpeedDiff = ratioSpeedDiff;
                bestRatio = {
                    :ratio => ratios[f][:ratio],
                    :front => ratios[f][:front],
                    :rear => ratios[f][:rear],
                    :spdiff => bestSpeedDiff,
                };
            }

        }
        return bestRatio;
    }

    //! Get the gear setting combined total speed index ()
    public function getGearsSpeedIndex(pFrontGear as Number , pRearGear as Number) as Number {
        if ((pFrontGear > 0) && (pRearGear>0)) {
            for (var f=0; f<ratios.size();f++) {
                if ( (ratios[f][:front] == pFrontGear) && (ratios[f][:rear]  == pRearGear)) {
                    return f+1;
                }
            }
        }
        return -1;
    }


    //! check all data validation
    public function isValid() as Boolean {
        if ((frontGears == null) || (frontGears == [])) {
            return false;
        }
        if ((rearGears == null) || (rearGears == [])) {
            return false;
        }
        if ((ratios == null) || (ratios == [])) {
            return false;
        }
        if ((ratiosPerRings == null) || (ratiosPerRings == [])) {
            return false;
        }
        if ((wheelC == null) || (wheelC < 1)) {
            return false;
        }
        return true;
    }
}


/*!
    Comparator Class for ratios array, using in Array.sort()
    Lang.Comparator
*/

//! sort ratios ascending order
//! The a and b must be [ratio, front, rear] Array
class RatiosComparatorAsc  {
    function compare(a as Lang.Object, b as Lang.Object) as Lang.Number {
        try {
            if (a[:ratio] > b[:ratio] ) {
                return 1;
            } else if (a[:ratio] < b[:ratio] ) {
                return -1;
            } else {
                return 0;
            }
        } catch (ex) {
            return 0;
        }
    }
}

//! sort ratios descending order
//! The a and b must be [ratio, front, rear] Array
class RatiosComparatorDesc  {
    function compare(a as Lang.Object, b as Lang.Object) as Lang.Number {
        try {
            if (a[:ratio] > b[:ratio] ) {
                return -1;
            } else if (a[:ratio] < b[:ratio] ) {
                return 1;
            } else {
                return 0;
            }
        } catch (ex) {
            return 0;
        }
    }
}

//! sort descending order
class rearGearComparator  {
    function compare(pa as Lang.Object, pb as Lang.Object) as Lang.Number {
        var a = (pa as String).toNumber();
        var b = (pb as String).toNumber();

        try {
            if (a > b ) {
                return -1;
            } else if (a < b ) {
                return 1;
            } else {
                return 0;
            }
        } catch (ex) {
            return 0;
        }
    }
}