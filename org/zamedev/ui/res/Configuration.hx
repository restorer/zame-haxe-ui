package org.zamedev.ui.res;

import org.zamedev.lib.ds.LinkedMap;

class Configuration {
    public var locale : String = "";
    public var aspect : String = "";

    public function new() {
    }

    public function toArray() : Array<String> {
        var result = new Array<String>();

        if (locale != "") {
            result.push(locale);
        }

        if (aspect != "") {
            result.push(aspect);
        }

        return result;
    }

    public function toMap() : LinkedMap<String, String> {
        var result = new LinkedMap<String, String>();

        if (locale != "") {
            result["locale"] = locale;
        }

        if (aspect != "") {
            result["aspect"] = aspect;
        }

        return result;
    }

    public function isEmpty() : Bool {
        return (locale == "" && aspect == "");
    }

    public function toQualifierString() : String {
        return toArray().join("-");
    }

    public function compareTo(other : Configuration) : Int {
        var result = Reflect.compare(locale, other.locale);

        if (result == 0) {
            result = Reflect.compare(aspect, other.aspect);
        }

        return result;
    }
}
