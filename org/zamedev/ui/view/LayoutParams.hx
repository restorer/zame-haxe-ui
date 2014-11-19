package org.zamedev.ui.view;

import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.res.TypedValue;

class LayoutParams {
    public var width:Dimension;
    public var height:Dimension;

    public function new() {
        width = Dimension.WRAP_CONTENT;
        height = Dimension.WRAP_CONTENT;
    }

    public function inflate(name:String, value:TypedValue):Bool {
        switch (name) {
            case "width":
                width = value.resolveDimension();
                return true;

            case "height":
                height = value.resolveDimension();
                return true;
        }

        return false;
    }

    public function onInflateFinished():Void {
    }
}
