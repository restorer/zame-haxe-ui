package org.zamedev.ui.graphics;

import openfl.errors.ArgumentError;

using StringTools;

class DimensionTools {
    public static function resolve(dimen:Dimension, viewSize:Float, layoutSize:Float, layoutWeight:Float = 1.0) {
        return switch(dimen) {
            case Dimension.WRAP_CONTENT:
                viewSize;

            case Dimension.MATCH_PARENT:
                layoutSize;

            case Dimension.EXACT(size):
                size;

            case Dimension.PERCENT(weight):
                layoutSize * weight;

            case Dimension.WEIGHT(weight):
                layoutSize * weight / layoutWeight;
        };
    }

    public static function parse(s:String):Dimension {
        s = s.trim().toLowerCase();

        if (s == "match_parent") {
            return Dimension.MATCH_PARENT;
        }

        if (s == "wrap_content") {
            return Dimension.WRAP_CONTENT;
        }

        var re = ~/^([+\-0-9.]+)w$/;

        if (re.match(s)) {
            var value = Std.parseFloat(re.matched(1));

            if (Math.isNaN(value)) {
                throw new ArgumentError("Parse error: " + s);
            }

            return Dimension.WEIGHT(value);
        }

        re = ~/^([+\-0-9.]+)%$/;

        if (re.match(s)) {
            var value = Std.parseFloat(re.matched(1));

            if (Math.isNaN(value)) {
                throw new ArgumentError("Parse error: " + s);
            }

            return Dimension.PERCENT(value / 100.0);
        }

        re = ~/^[+\-0-9.]+$/;

        if (re.match(s)) {
            var value = Std.parseFloat(s);

            if (Math.isNaN(value)) {
                throw new ArgumentError("Parse error: " + s);
            }

            return Dimension.EXACT(value);
        }

        throw new ArgumentError("Parse error: " + s);
    }
}
