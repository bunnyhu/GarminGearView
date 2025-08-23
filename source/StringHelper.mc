import Toybox.Lang;

//! Expanded String utilities
module StringHelper {
    public const VALID_NUMS = "0123456789";

    //! Explode a String list to Array
    public function strExplode(pString as String, pSeparator as String) as Array {
        var result = [];
        var sep = null;
        try {
            while (pString.length() > 0) {
                sep = pString.find(pSeparator);
                if (pString.find(pSeparator) != null) {
                    result.add( pString.substring(null, sep) );
                    pString = pString.substring(sep+1, null);
                } else {
                    result.add( pString );
                    pString = "";
                }
            }
        } catch (ex) {
        }
        return result;
    }

    //! Trim the string from both sides
    public function strTrim(pString as String) as String {
        if (pString == null) {
            return "";
        }
        while (pString.substring(0, 1) == " ") {
            pString = pString.substring(1, null);
        }
        while (pString.substring(pString.length() - 1, null) == " ") {
            pString = pString.substring(null, pString.length() - 1);
        }
        return pString;
    }

    //! String validator
    //!
    //! @param pString The string for validating
    //! @param pValidChars All valid characters (case sensitive)
    //! @param maxLength Maximum length or -1 if no need to check that
    //! @return true if the string is valid
    public function strValidator(pString as String , pValidChars as String, maxLength as Number) as Boolean {
        if ((maxLength != -1) && (pString.length() > maxLength)) {
            return false;
        }
        for (var f=0; f<pString.length(); f++) {
            if (pValidChars.find(pString.substring(f, f+1)) == null ) {
                return false;
            }
        }
        return true;
    }

    //! Check the String and give back the valid version
    //!
    //! @param pString The string for validating
    //! @param pValidChars All valid characters (case sensitive)
    //! @param maxLength Maximum length or -1 if no need to check that
    //! @return String with only valid content
    public function getValidString(pString as String , pValidChars as String, maxLength as Number) as String {
        var newString = "";
        for (var f=0; f<pString.length(); f++) {
            if (pValidChars.find(pString.substring(f, f+1)) != null ) {
                newString += pString.substring(f, f+1);
            }
        }

        if ((maxLength != -1) && (newString.length() > maxLength)) {
            newString = newString.substring(null, maxLength);
        }

        return newString;
    }

}