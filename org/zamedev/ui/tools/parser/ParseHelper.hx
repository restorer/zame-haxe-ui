package org.zamedev.ui.tools.parser;

import org.zamedev.ui.errors.UiParseError;
import org.zamedev.ui.graphics.TextAlignExt;
import org.zamedev.ui.view.ViewVisibility;
import org.zamedev.ui.widget.LinearLayoutOrientation;

using StringTools;

class ParseHelper {
    public static function parseRef(textValue:String):RefInfo {
        var re = ~/^\s*@([a-z]+)\/([a-zA-Z0-9_]+)\s*$/;

        if (!re.match(textValue)) {
            return null;
        }

        return {
            type: re.matched(1),
            name: re.matched(2),
        };
    }

    public static function parseFloat(textValue:String):Float {
        var value = Std.parseFloat(textValue.trim());

        if (Math.isNaN(value)) {
            throw new UiParseError('${textValue} is not a float');
        }

        return value;
    }

    public static function parseBool(textValue:String):Bool {
        switch (textValue.trim().toLowerCase()) {
            case "1" | "true" | "on" | "yes":
                return true;

            default:
                return false;
        }
    }

    public static function parseStringArray(textValue:String):Array<String> {
        return textValue.split("|").map(function (v) {
            return v.trim();
        }).filter(function (v) {
            return (v.length > 0);
        });
    }

    public static function parseTextAlign(textValue:String):TextAlignExt {
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
                throw new UiParseError('unknown text align "${textValue}"');
        }
    }

    public static function parseViewVisibility(textValue:String):ViewVisibility {
        switch (textValue) {
            case "visible":
                return ViewVisibility.VISIBLE;

            case "invisible":
                return ViewVisibility.INVISIBLE;

            case "gone":
                return ViewVisibility.GONE;

            default:
                throw new UiParseError('unknown view visibility "${textValue}"');
        }
    }

    public static function parseLinearLayoutOrientation(textValue:String):LinearLayoutOrientation {
        switch (textValue) {
            case "vertical":
                return LinearLayoutOrientation.VERTICAL;

            case "horizontal":
                return LinearLayoutOrientation.HORIZONTAL;

            default:
                throw new UiParseError('unknown linear layout orientation "${textValue}"');
        }
    }
}
