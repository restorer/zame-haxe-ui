package org.zamedev.ui.res;

import openfl.errors.ArgumentError;
import org.zamedev.ui.graphics.Color;
import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.DimensionTools;
import org.zamedev.ui.graphics.Drawable;

using StringTools;

class TypedValue {
    private var resourceManager:ResourceManager;
    private var textValue:String;

    public function new(resourceManager:ResourceManager, textValue:String) {
        this.resourceManager = resourceManager;
        this.textValue = textValue;
    }

    public function toString():String {
        return '[TypedValue ${textValue}]';
    }

    public function resolveDrawable():Drawable {
        return resourceManager.getDrawable(textValue);
    }

    public function resolveFloat():Float {
        if (textValue.substr(0, 1) == "@") {
            var dimen = resourceManager.getDimension(textValue);

            switch (dimen) {
                case Dimension.EXACT(value):
                    return value;

                default:
                    throw new ArgumentError("Must be exact value: " + textValue);
            }
        } else {
            var value = Std.parseFloat(textValue);

            if (Math.isNaN(value)) {
                throw new ArgumentError("Parse error: " + textValue);
            }

            return value;
        }
    }

    public function resolveDimension():Dimension {
        if (textValue.substr(0, 1) == "@") {
            return resourceManager.getDimension(textValue);
        } else {
            return DimensionTools.parse(textValue);
        }
    }

    public function resolveColor():UInt {
        if (textValue.substr(0, 1) == "@") {
            return resourceManager.getColor(textValue);
        } else {
            return Color.parse(textValue);
        }
    }

    public function resolveString():String {
        if (textValue.substr(0, 1) == "@") {
            return resourceManager.getString(textValue);
        } else {
            return textValue;
        }
    }

    public function resolveFont():String {
        if (textValue.substr(0, 1) == "@") {
            return resourceManager.getFont(textValue);
        } else {
            return textValue;
        }
    }

    public function resolveSelector():Selector {
        return resourceManager.getSelector(textValue);
    }

    public function resolveBool():Bool {
        switch (textValue.trim().toLowerCase()) {
            case "1" | "true" | "on" | "yes":
                return true;

            default:
                return false;
        }
    }
}
