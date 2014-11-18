package org.zamedev.ui.graphics;

import openfl.errors.ArgumentError;

using StringTools;

class GravityTools {
    public static function parse(s:String):Gravity {
        switch (s.trim().toLowerCase()) {
            case "none":
                return Gravity.NONE;

            case "left":
                return Gravity.LEFT;

            case "right":
                return Gravity.RIGHT;

            case "top":
                return Gravity.TOP;

            case "bottom":
                return Gravity.BOTTOM;

            case "center":
                return Gravity.CENTER;

            case "center_horizontal":
                return Gravity.CENTER_HORIZONTAL;

            case "center_vertical":
                return Gravity.CENTER_VERTICAL;

            case "start":
                return Gravity.START;

            case "end":
                return Gravity.END;

            default:
                throw new ArgumentError("Parse error: " + s);
        }
    }
}
