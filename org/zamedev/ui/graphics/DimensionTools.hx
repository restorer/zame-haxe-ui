package org.zamedev.ui.graphics;

import org.zamedev.ui.errors.UiParseError;

using StringTools;

class DimensionTools {
    public static function resolveVertical(relWidth:Float, relHeight:Float, type:DimensionType, vertical:Bool):Bool {
        switch (type) {
            case DimensionType.UNSPECIFIED:
                return vertical;

            case DimensionType.HEIGHT:
                return true;

            case DimensionType.WIDTH:
                return false;

            case DimensionType.MIN:
                return (relHeight < relWidth);

            case DimensionType.MAX:
                return (relHeight > relWidth);
        }
    }

    public static function resolveWeight(weight:Float, size:Float, sizeWeightSum:Float, useWeightSum:Bool):Float {
        return (useWeightSum
            ? (weight * size / sizeWeightSum)
            : (weight * size)
        );
    }

    public static function parse(s:String):Dimension {
        s = s.trim().toLowerCase();

        if (s == "match_parent") {
            return Dimension.MATCH_PARENT;
        }

        if (s == "wrap_content") {
            return Dimension.WRAP_CONTENT;
        }

        var re = ~/^([+\-0-9.]+)(%)?(?:(p|s)(w|h|min|max)?)?$/;

        if (re.match(s)) {
            var value = Std.parseFloat(re.matched(1));

            if (Math.isNaN(value)) {
                throw new UiParseError(s);
            }

            if (re.matched(2) == null && re.matched(3) == null && re.matched(4) == null) {
                return Dimension.EXACT(value);
            }

            var useWeightSum = (re.matched(2) == null);

            if (!useWeightSum) {
                value /= 100.0;
            }

            var dimensionType = switch(re.matched(4)) {
                case "w":
                    DimensionType.WIDTH;

                case "h":
                    DimensionType.HEIGHT;

                case "min":
                    DimensionType.MIN;

                case "max":
                    DimensionType.MAX;

                default:
                    DimensionType.UNSPECIFIED;
            };

            if (re.matched(3) == "s") {
                return Dimension.WEIGHT_STAGE(value, dimensionType, useWeightSum);
            } else {
                return Dimension.WEIGHT_PARENT(value, dimensionType, useWeightSum);
            }
        }

        throw new UiParseError(s);
    }
}
