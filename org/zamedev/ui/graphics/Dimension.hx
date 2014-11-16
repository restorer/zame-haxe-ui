package org.zamedev.ui.graphics;

import openfl.errors.ArgumentError;

enum DimensionType {
    EXACT;
    WEIGHT;
}

class Dimension {
    public var type:DimensionType;
    public var value:Float;

    public function new(type:DimensionType = null, value:Float = 0.0) {
        this.type = (type == null ? DimensionType.EXACT : type);
        this.value = value;
    }

    public function toString():String {
        return '[Dimension type=${type} value=${value}]';
    }

    public static function parse(s:String):Dimension {
        var re = ~/^\s*([+\-0-9.]+)%\s*$/;

        if (re.match(s)) {
            var value = Std.parseFloat(re.matched(1));

            if (Math.isNaN(value)) {
                throw new ArgumentError("Parse error: " + s);
            }

            return new Dimension(DimensionType.WEIGHT, value / 100.0);
        }

        var re = ~/^\s*([+\-0-9.]+)\s*$/;

        if (re.match(s)) {
            var value = Std.parseFloat(re.matched(1));

            if (Math.isNaN(value)) {
                throw new ArgumentError("Parse error: " + s);
            }

            return new Dimension(DimensionType.EXACT, value);
        }

        throw new ArgumentError("Parse error: " + s);
    }
}
