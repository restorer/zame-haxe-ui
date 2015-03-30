package org.zamedev.ui.view;

import org.zamedev.ui.Context;
import org.zamedev.ui.internal.ShapeExt;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.Styleable;

class Rect extends View {
    private var shape:ShapeExt;
    private var _fillColor:UInt;
    private var _ellipseWidth:Float;
    private var _ellipseHeight:Float;

    public var fillColor(get, set):UInt;
    public var ellipseWidth(get, set):Float;
    public var ellipseHeight(get, set):Float;
    public var ellipseSize(never, set):Float;

    #if dom
        public var buttonMode(get, set):Bool;
    #end

    @:keep
    public function new(context:Context) {
        super(context);

        _sprite.addChild(shape = new ShapeExt());
        _fillColor = 0;
        _ellipseWidth = 0.0;
        _ellipseHeight = 0.0;
    }

    override private function _inflate(attId:Styleable, value:Dynamic):Bool {
        if (super._inflate(attId, value)) {
            return true;
        }

        switch (attId) {
            case Styleable.fillColor:
                fillColor = cast value;
                return true;

            case Styleable.ellipseWidth:
                ellipseWidth = computeDimension(cast value, false);
                return true;

            case Styleable.ellipseHeight:
                ellipseHeight = computeDimension(cast value, true);
                return true;

            case Styleable.ellipseSize:
                ellipseSize = computeDimension(cast value, false);
                return true;

            default:
                return false;
        }
    }

    override private function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
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

    #if dom
        @:noCompletion
        private function get_buttonMode():Bool {
            return shape.buttonMode;
            return false;
        }

        @:noCompletion
        private function set_buttonMode(value:Bool):Bool {
            shape.buttonMode = value;
            return value;
        }
    #end
}
