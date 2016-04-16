package org.zamedev.ui.tools.parser;

import org.zamedev.ui.errors.UiParseError;
import org.zamedev.ui.graphics.TextAlignExt;
import org.zamedev.ui.i18n.Quantity;
import org.zamedev.ui.tools.generator.GenPosition;
import org.zamedev.ui.view.ViewVisibility;
import org.zamedev.ui.widget.LinearLayoutOrientation;

using StringTools;

class ParseHelper {
    public static function parseRef(textValue : String) : RefInfo {
        var re = ~/^\s*@([a-z]+)\/([a-zA-Z0-9_]+)\s*$/;

        if (!re.match(textValue)) {
            return null;
        }

        return {
            type: re.matched(1),
            name: re.matched(2),
        };
    }

    public static function parseInt(textValue : String, pos : GenPosition) : Int {
        var value = Std.parseInt(textValue.trim());

        if (value == null) {
            throw new UiParseError('"${textValue}" is not an int', pos);
        }

        return value;
    }

    public static function parseFloat(textValue : String, pos : GenPosition) : Float {
        var value = Std.parseFloat(textValue.trim());

        if (Math.isNaN(value)) {
            throw new UiParseError('"${textValue}" is not a float', pos);
        }

        return value;
    }

    public static function parseBool(textValue : String) : Bool {
        switch (textValue.trim().toLowerCase()) {
            case "1" | "true" | "on" | "yes":
                return true;

            default:
                return false;
        }
    }

    public static function parseStringArray(textValue : String) : Array<String> {
        return textValue.split("|").map(function (v) {
            return v.trim();
        }).filter(function (v) {
            return (v.length > 0);
        });
    }

    public static function parseTextAlign(textValue : String, pos : GenPosition) : TextAlignExt {
        switch (textValue) {
            case "center":
                return TextAlignExt.CENTER;

            case "justify":
                return TextAlignExt.JUSTIFY;

            case "right":
                return TextAlignExt.RIGHT;

            case "left":
                return TextAlignExt.LEFT;

            default:
                throw new UiParseError('Unknown text align "${textValue}"', pos);
        }
    }

    public static function parseViewVisibility(textValue : String, pos : GenPosition) : ViewVisibility {
        switch (textValue) {
            case "visible":
                return ViewVisibility.VISIBLE;

            case "invisible":
                return ViewVisibility.INVISIBLE;

            case "gone":
                return ViewVisibility.GONE;

            default:
                throw new UiParseError('Unknown view visibility "${textValue}"', pos);
        }
    }

    public static function parseLinearLayoutOrientation(textValue : String, pos : GenPosition) : LinearLayoutOrientation {
        switch (textValue) {
            case "vertical":
                return LinearLayoutOrientation.VERTICAL;

            case "horizontal":
                return LinearLayoutOrientation.HORIZONTAL;

            default:
                throw new UiParseError('Unknown linear layout orientation "${textValue}"', pos);
        }
    }

    public static function parseQuantity(textValue : String, pos : GenPosition) : Quantity {
        switch (textValue) {
            case "zero":
                return Quantity.ZERO;

            case "one":
                return Quantity.ONE;

            case "two":
                return Quantity.TWO;

            case "few":
                return Quantity.FEW;

            case "many":
                return Quantity.MANY;

            case "other":
                return Quantity.OTHER;

            default:
                throw new UiParseError('Unknown quantity "${textValue}"', pos);
        }
    }
}
