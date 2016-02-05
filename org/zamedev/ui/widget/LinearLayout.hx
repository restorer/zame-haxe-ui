package org.zamedev.ui.widget;

import org.zamedev.ui.Context;
import org.zamedev.ui.graphics.GravityType;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.Styleable;
import org.zamedev.ui.view.LayoutParams;
import org.zamedev.ui.view.ViewGroup;
import org.zamedev.ui.view.ViewVisibility;

using StringTools;

class LinearLayout extends ViewGroup {
    private var _orientation : LinearLayoutOrientation;
    private var _marginBetween : Float;

    public var orientation(get, set) : LinearLayoutOrientation;
    public var marginBetween(get, set) : Float;

    @:keep
    public function new(context : Context, ?orientation : LinearLayoutOrientation) {
        super(context);
        this._orientation = (orientation == null ? LinearLayoutOrientation.VERTICAL : orientation);
        this._marginBetween = 0.0;
    }

    override public function createLayoutParams() : LayoutParams {
        return new LinearLayoutParams();
    }

    override private function _inflate(attId : Styleable, value : Dynamic) : Bool {
        if (super._inflate(attId, value)) {
            return true;
        }

        switch (attId) {
            case Styleable.orientation:
                orientation = cast value;
                return true;

            case Styleable.marginBetween:
                marginBetween = computeDimension(cast value, false);
                return true;

            default:
                return false;
        }
    }

    override private function measureAndLayout(widthSpec : MeasureSpec, heightSpec : MeasureSpec) : Bool {
        if (super.measureAndLayout(widthSpec, heightSpec)) {
            return true;
        }

        for (child in children) {
            var layoutParams = cast(child.layoutParams, LinearLayoutParams);

            if (child.visibility != ViewVisibility.GONE) {
                layoutParams._marginLeftComputed = computeDimension(layoutParams.marginLeft, false);
                layoutParams._marginRightComputed = computeDimension(layoutParams.marginRight, false);
                layoutParams._marginTopComputed = computeDimension(layoutParams.marginTop, true);
                layoutParams._marginBottomComputed = computeDimension(layoutParams.marginBottom, true);
            } else {
                layoutParams._marginLeftComputed = 0.0;
                layoutParams._marginRightComputed = 0.0;
                layoutParams._marginTopComputed = 0.0;
                layoutParams._marginBottomComputed = 0.0;
            }
        }

        measureSelf(widthSpec, heightSpec);

        var position : Float = 0.0;
        var currentMarginBetween : Float = 0.0;

        for (child in children) {
            var layoutParams : LinearLayoutParams = cast child.layoutParams;

            if (_orientation == LinearLayoutOrientation.HORIZONTAL) {
                position += layoutParams._marginLeftComputed + currentMarginBetween;
                child.x = position;
                position += child.width + layoutParams._marginRightComputed;

                switch (layoutParams.gravity.verticalType) {
                    case GravityType.END:
                        child.ey = _height - layoutParams._marginBottomComputed;

                    case GravityType.CENTER:
                        child.cy = _height / 2;

                    default:
                        child.y = layoutParams._marginTopComputed;
                }
            } else {
                position += layoutParams._marginTopComputed + currentMarginBetween;
                child.y = position;
                position += child.height + layoutParams._marginBottomComputed;

                switch (layoutParams.gravity.horizontalType) {
                    case GravityType.END:
                        child.ex = _width - layoutParams._marginRightComputed;

                    case GravityType.CENTER:
                        child.cx = _width / 2;

                    default:
                        child.x = layoutParams._marginLeftComputed;
                }
            }

            currentMarginBetween = _marginBetween;
        }

        return true;
    }

    override private function refineSelfMeasure(measureWidth : Bool, measureHeight : Bool) : Void {
        if (measureWidth) {
            _width = 0.0;
        }

        if (measureHeight) {
            _height = 0.0;
        }

        var currentMarginBetween : Float = 0.0;

        for (child in children) {
            var layoutParams : LinearLayoutParams = cast child.layoutParams;

            if (measureWidth) {
                if (_orientation == LinearLayoutOrientation.HORIZONTAL && layoutParams._measuredWidth < 0.0) {
                    _width = -1.0;
                    measureWidth = false;
                } else {
                    var size = layoutParams._measuredWidth + layoutParams._marginLeftComputed + layoutParams._marginRightComputed;

                    if (_orientation == LinearLayoutOrientation.HORIZONTAL) {
                        _width += size + currentMarginBetween;
                    } else {
                        _width = Math.max(_width, size);
                    }
                }
            }

            if (measureHeight) {
                if (_orientation == LinearLayoutOrientation.VERTICAL && layoutParams._measuredHeight < 0.0) {
                    _height = -1.0;
                    measureHeight = false;
                } else {
                    var size = layoutParams._measuredHeight + layoutParams._marginTopComputed + layoutParams._marginBottomComputed;

                    if (_orientation == LinearLayoutOrientation.VERTICAL) {
                        _height += size + currentMarginBetween;
                    } else {
                        _height = Math.max(_height, size);
                    }
                }
            }

            if (!measureWidth && !measureHeight) {
                break;
            }

            currentMarginBetween = _marginBetween;
        }
    }

    override private function computeMatchParentMeasureSpec(childLayoutParams : LayoutParams, size : Float, vertical : Bool) : MeasureSpec {
        var layoutParams = cast(childLayoutParams, LinearLayoutParams);

        return MeasureSpec.EXACT(size - (vertical
            ? (layoutParams._marginTopComputed + layoutParams._marginBottomComputed)
            : (layoutParams._marginLeftComputed + layoutParams._marginRightComputed)
        ));
    }

    @:noCompletion
    private function get_orientation() : LinearLayoutOrientation {
        return _orientation;
    }

    @:noCompletion
    private function set_orientation(value : LinearLayoutOrientation) : LinearLayoutOrientation {
        _orientation = value;
        requestLayout();
        return value;
    }

    @:noCompletion
    private function get_marginBetween() : Float {
        return _marginBetween;
    }

    @:noCompletion
    private function set_marginBetween(value : Float) : Float {
        _marginBetween = value;
        requestLayout();
        return value;
    }
}
