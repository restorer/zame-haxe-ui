package org.zamedev.ui.view;

import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.res.TypedValue;
import org.zamedev.ui.res.MeasureSpec;

class LayoutParams {
    public var width:Dimension;
    public var height:Dimension;

    public var _widthSpec:MeasureSpec;
    public var _heightSpec:MeasureSpec;
    public var _measured:Bool;
    public var _measuredWidth:Float;
    public var _measuredHeight:Float;

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

    public function onInflateStarted():Void {
    }

    public function onInflateFinished():Void {
    }
}
