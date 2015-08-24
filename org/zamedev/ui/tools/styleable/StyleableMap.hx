package org.zamedev.ui.tools.styleable;

import org.zamedev.lib.ds.LinkedMap;
import org.zamedev.ui.errors.UiParseError;

class StyleableMap {
    private static var _nameToTypeMap:LinkedMap<String, StyleableType> = null;

    public static function getNameToTypeMap():LinkedMap<String, StyleableType> {
        if (_nameToTypeMap != null) {
            return _nameToTypeMap;
        }

        var m = new LinkedMap<String, StyleableType>();

        m["id"] = StyleableType.STRING;
        m["tags"] = StyleableType.STRING_ARRAY;
        m["selector"] = StyleableType.SELECTOR;
        m["widthWeightSum"] = StyleableType.DIMENSION;
        m["heightWeightSum"] = StyleableType.DIMENSION;
        m["visibility"] = StyleableType.VIEW_VISIBILITY;
        m["alpha"] = StyleableType.FLOAT;
        m["rotation"] = StyleableType.FLOAT;
        m["offsetX"] = StyleableType.DIMENSION;
        m["offsetY"] = StyleableType.DIMENSION;
        m["drawable"] = StyleableType.DRAWABLE;
        m["scaleX"] = StyleableType.FLOAT;
        m["scaleY"] = StyleableType.FLOAT;
        m["scale"] = StyleableType.FLOAT;
        m["fillColor"] = StyleableType.COLOR;
        m["ellipseWidth"] = StyleableType.DIMENSION;
        m["ellipseHeight"] = StyleableType.DIMENSION;
        m["ellipseSize"] = StyleableType.DIMENSION;
        m["textColor"] = StyleableType.COLOR;
        m["textSize"] = StyleableType.DIMENSION;
        m["textLeading"] = StyleableType.DIMENSION;
        m["textAlign"] = StyleableType.TEXT_ALIGN;
        m["font"] = StyleableType.FONT;
        m["text"] = StyleableType.STRING;
        m["htmlText"] = StyleableType.STRING;
        m["background"] = StyleableType.DRAWABLE;
        m["leftIcon"] = StyleableType.DRAWABLE;
        m["rightIcon"] = StyleableType.DRAWABLE;
        m["upIcon"] = StyleableType.DRAWABLE;
        m["downIcon"] = StyleableType.DRAWABLE;
        m["backgroundOffsetX"] = StyleableType.DIMENSION;
        m["backgroundOffsetY"] = StyleableType.DIMENSION;
        m["leftIconOffsetX"] = StyleableType.DIMENSION;
        m["leftIconOffsetY"] = StyleableType.DIMENSION;
        m["rightIconOffsetX"] = StyleableType.DIMENSION;
        m["rightIconOffsetY"] = StyleableType.DIMENSION;
        m["upIconOffsetX"] = StyleableType.DIMENSION;
        m["upIconOffsetY"] = StyleableType.DIMENSION;
        m["downIconOffsetX"] = StyleableType.DIMENSION;
        m["downIconOffsetY"] = StyleableType.DIMENSION;
        m["textOffsetX"] = StyleableType.DIMENSION;
        m["textOffsetY"] = StyleableType.DIMENSION;
        m["leftIconMargin"] = StyleableType.DIMENSION;
        m["rightIconMargin"] = StyleableType.DIMENSION;
        m["upIconMargin"] = StyleableType.DIMENSION;
        m["downIconMargin"] = StyleableType.DIMENSION;
        m["disabled"] = StyleableType.BOOL;
        m["leftIconAlpha"] = StyleableType.FLOAT;
        m["rightIconAlpha"] = StyleableType.FLOAT;
        m["upIconAlpha"] = StyleableType.FLOAT;
        m["downIconAlpha"] = StyleableType.FLOAT;
        m["orientation"] = StyleableType.LINEAR_LAYOUT_ORIENTATION;
        m["selected"] = StyleableType.BOOL;
        m["groupTag"] = StyleableType.STRING;
        m["cycle"] = StyleableType.BOOL;
        m["verticalFadeSize"] = StyleableType.DIMENSION;
        m["horizontalFadeSize"] = StyleableType.DIMENSION;
        m["scrollable"] = StyleableType.BOOL;
        m["placeholderTextColor"] = StyleableType.COLOR;
        m["placeholderText"] = StyleableType.STRING;
        m["paddingLeft"] = StyleableType.DIMENSION;
        m["paddingRight"] = StyleableType.DIMENSION;
        m["paddingTop"] = StyleableType.DIMENSION;
        m["paddingBottom"] = StyleableType.DIMENSION;
        m["paddingHorizontal"] = StyleableType.DIMENSION;
        m["paddingVertical"] = StyleableType.DIMENSION;
        m["padding"] = StyleableType.DIMENSION;

        m["layout_width"] = StyleableType.DIMENSION;
        m["layout_height"] = StyleableType.DIMENSION;
        m["layout_x"] = StyleableType.DIMENSION;
        m["layout_y"] = StyleableType.DIMENSION;
        m["layout_cx"] = StyleableType.DIMENSION;
        m["layout_cy"] = StyleableType.DIMENSION;
        m["layout_ex"] = StyleableType.DIMENSION;
        m["layout_ey"] = StyleableType.DIMENSION;
        m["layout_gravity"] = StyleableType.GRAVITY;
        m["layout_marginLeft"] = StyleableType.DIMENSION;
        m["layout_marginRight"] = StyleableType.DIMENSION;
        m["layout_marginTop"] = StyleableType.DIMENSION;
        m["layout_marginBottom"] = StyleableType.DIMENSION;
        m["layout_marginHorizontal"] = StyleableType.DIMENSION;
        m["layout_marginVertical"] = StyleableType.DIMENSION;
        m["layout_margin"] = StyleableType.DIMENSION;

        _nameToTypeMap = m;
        return _nameToTypeMap;
    }

    public static function getTypeByName(name:String):StyleableType {
        var type = getNameToTypeMap()[name];

        if (type == null) {
            throw new UiParseError('unknown styleable name "${name}"');
        }

        return type;
    }
}
