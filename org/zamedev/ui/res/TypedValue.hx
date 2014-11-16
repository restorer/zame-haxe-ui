package org.zamedev.ui.res;

import openfl.errors.ArgumentError;
import org.zamedev.ui.graphics.Color;
import org.zamedev.ui.graphics.Drawable;

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
            return resourceManager.getDimen(textValue).value;
        } else {
            var value = Std.parseFloat(textValue);

            if (Math.isNaN(value)) {
                throw new ArgumentError("Parse error: " + textValue);
            }

            return value;
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
}
