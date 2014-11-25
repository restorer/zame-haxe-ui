package org.zamedev.ui.view;

import openfl.display.Shape;
import org.zamedev.ui.Context;
import org.zamedev.ui.res.TypedValue;
import org.zamedev.ui.res.MeasureSpec;

class Rect extends View {
    private var shape:Shape;
    private var _fillColor:UInt;
    private var _ellipseWidth:Float;
    private var _ellipseHeight:Float;

    public var fillColor(get, set):UInt;
    public var ellipseWidth(get, set):Float;
    public var ellipseHeight(get, set):Float;
    public var ellipseSize(never, set):Float;

    public function new(context:Context) {
        super(context);

        _sprite.addChild(shape = new Shape());
        _fillColor = 0;
        _ellipseWidth = 0.0;
        _ellipseHeight = 0.0;
    }

    override public function inflate(name:String, value:TypedValue):Bool {
        if (super.inflate(name, value)) {
            return true;
        }

        switch (name) {
            case "fillColor":
                fillColor = value.resolveColor();
                return true;

            case "ellipseWidth":
                ellipseWidth = computeDimension(value.resolveDimension(), false);
                return true;

            case "ellipseHeight":
                ellipseHeight = computeDimension(value.resolveDimension(), true);
                return true;

            case "ellipseSize":
                ellipseSize = computeDimension(value.resolveDimension(), false);
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
            shape.graphics.beginFill(_fillColor);

            if (_ellipseWidth <= 0.0 || _ellipseHeight <= 0.0) {
                shape.graphics.drawRect(0, 0, _width, _height);
            } else {
                shape.graphics.drawRoundRect(0, 0, _width, _height, _ellipseWidth, _ellipseHeight);
            }

            shape.graphics.endFill();
        }

        return true;
    }

    @:noCompletion
    private function get_fillColor():UInt {
        return _fillColor;
    }

    @:noCompletion
    private function set_fillColor(value:UInt):UInt {
        _fillColor = value;
        requestLayout();
        return value;
    }

    @:noCompletion
    private function get_ellipseWidth():Float {
        return _ellipseWidth;
    }

    @:noCompletion
    private function set_ellipseWidth(value:Float):Float {
        _ellipseWidth = value;
        requestLayout();
        return value;
    }

    @:noCompletion
    private function get_ellipseHeight():Float {
        return _ellipseHeight;
    }

    @:noCompletion
    private function set_ellipseHeight(value:Float):Float {
        _ellipseHeight = value;
        requestLayout();
        return value;
    }

    @:noCompletion
    private function set_ellipseSize(value:Float):Float {
        _ellipseWidth = value;
        _ellipseHeight = value;
        requestLayout();
        return value;
    }
}
