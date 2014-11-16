package org.zamedev.ui.graphics;

import openfl.errors.ArgumentError;

class Color {
    public static function parse(s:String):UInt {
        var re = ~/^\s*#([0-9A-Fa-f]{6})\s*$/;

        if (re.match(s)) {
            var val = Std.parseInt("0x" + re.matched(1));

            if (val == null) {
                throw new ArgumentError("Parse error: " + s);
            }

            return val;
        }

        re = ~/^\s*#([0-9A-Fa-f]{3})\s*$/;

        if (re.match(s)) {
            var val = Std.parseInt("0x" + re.matched(1));

            if (val == null) {
                throw new ArgumentError("Parse error: " + s);
            }

            var r = (val & 0xf00) >> 8;
            var g = (val & 0xf0) >> 4;
            var b = val & 0xf;

            return (r << 20) | (r << 16) | (g << 12) | (g << 8) | (b << 4) | b;
        }

        re = ~/^\s*rgb\s*\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)\s*$/;

        if (re.match(s)) {
            var r = Std.parseInt(re.matched(1));
            var g = Std.parseInt(re.matched(2));
            var b = Std.parseInt(re.matched(3));

            if (r == null || r > 255 || g == null || g > 255 || b == null || b > 255) {
                throw new ArgumentError("Parse error: " + s);
            }

            return (r << 16) | (g << 8) | b;
        }

        throw new ArgumentError("Parse error: " + s);
    }
}
