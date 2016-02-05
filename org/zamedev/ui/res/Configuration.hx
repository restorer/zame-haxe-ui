package org.zamedev.ui.res;

import org.zamedev.lib.ds.LinkedMap;

class Configuration {
    public var locale : String = "";
    public var aspect : String = "";
    public var orientation : String = "";
    public var target : String = "";
    public var subTarget : String = "";

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

        if (orientation != "") {
            result.push(orientation);
        }

        if (target != "") {
            result.push(target);
        }

        if (subTarget != "") {
            result.push(subTarget);
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

        if (orientation != "") {
            result["orientation"] = orientation;
        }

        if (target != "") {
            result["target"] = target;
        }

        if (subTarget != "") {
            result["subTarget"] = subTarget;
        }

        return result;
    }

    public function isEmpty() : Bool {
        return (locale == "" && aspect == "" && orientation == "" && target == "" && subTarget == "");
    }

    public function toQualifierString() : String {
        return toArray().join("-");
    }

    public function compareTo(other : Configuration) : Int {
        var result = Reflect.compare(locale, other.locale);

        if (result == 0) {
            result = Reflect.compare(aspect, other.aspect);
        }

        if (result == 0) {
            result = Reflect.compare(orientation, other.orientation);
        }

        if (result == 0) {
            result = Reflect.compare(target, other.target);
        }

        if (result == 0) {
            result = Reflect.compare(subTarget, other.subTarget);
        }

        return result;
    }
}
