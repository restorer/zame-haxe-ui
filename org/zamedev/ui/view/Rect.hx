package org.zamedev.ui.view;

import openfl.display.Shape;
import org.zamedev.ui.Context;
import org.zamedev.ui.res.TypedValue;
import org.zamedev.ui.res.MeasureSpec;

class Rect extends View {
    private var shape:Shape;

    public var fillColor(default, set):UInt;

    public function new(context:Context) {
        super(context);

        _sprite.addChild(shape = new Shape());
        fillColor = 0;
    }

    override public function inflate(name:String, value:TypedValue):Bool {
        if (super.inflate(name, value)) {
            return true;
        }

        switch (name) {
            case "fillColor":
                fillColor = value.resolveColor();
                return true;
        }

        return false;
    }

    override public function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
        if (super.measureAndLayout(widthSpec, heightSpec)) {
            return true;
        }

        switch (widthSpec) {
            case MeasureSpec.UNSPECIFIED:
                _width = 0;

            case MeasureSpec.AT_MOST(size) | MeasureSpec.EXACT(size):
                _width = size;
        }

        switch (heightSpec) {
            case MeasureSpec.UNSPECIFIED:
                _height = 0;

            case MeasureSpec.AT_MOST(size) | MeasureSpec.EXACT(size):
                _height = size;
        }

        shape.graphics.clear();

        if (_width > 0 && _height > 0) {
            shape.graphics.beginFill(fillColor);
            shape.graphics.drawRect(0, 0, _width, _height);
            shape.graphics.endFill();
        }

        return true;
    }

    @:noCompletion
    private function set_fillColor(value:UInt):UInt {
        fillColor = value;
        requestLayout();
        return value;
    }
}
