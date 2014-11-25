package org.zamedev.ui.widget;

import openfl.errors.ArgumentError;
import org.zamedev.ui.Context;
import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.GravityType;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.TypedValue;
import org.zamedev.ui.view.LayoutParams;
import org.zamedev.ui.view.View;
import org.zamedev.ui.view.ViewGroup;

using StringTools;

enum LinearLayoutOrientation {
    VERTICAL;
    HORIZONTAL;
}

class LinearLayout extends ViewGroup {
    private var _orientation:LinearLayoutOrientation;

    public var orientation(get, set):LinearLayoutOrientation;

    public function new(context:Context) {
        super(context);

        orientation = LinearLayoutOrientation.VERTICAL;
    }

    override public function createLayoutParams():LayoutParams {
        return new LinearLayoutParams();
    }

    override public function inflate(name:String, value:TypedValue):Bool {
        if (super.inflate(name, value)) {
            return true;
        }

        switch (name) {
            case "orientation":
                switch (value.resolveString().trim().toLowerCase()) {
                    case "vertical":
                        orientation = LinearLayoutOrientation.VERTICAL;

                    case "horizontal":
                        orientation = LinearLayoutOrientation.HORIZONTAL;

                    default:
                        throw new ArgumentError("Unknown orientation value: " + value.resolveString());
                }

                return true;
        }

        return false;
    }

    override public function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
        if (super.measureAndLayout(widthSpec, heightSpec)) {
            return true;
        }

        for (child in children) {
            var layoutParams = cast(child.layoutParams, LinearLayoutParams);

            layoutParams._marginLeftComputed = computeDimension(layoutParams.marginLeft, false);
            layoutParams._marginRightComputed = computeDimension(layoutParams.marginRight, false);
            layoutParams._marginTopComputed = computeDimension(layoutParams.marginTop, true);
            layoutParams._marginBottomComputed = computeDimension(layoutParams.marginBottom, true);
        }

        measureSelf(widthSpec, heightSpec);

        var position:Float = 0.0;

        for (child in children) {
            var layoutParams = cast(child.layoutParams, LinearLayoutParams);

            if (orientation == LinearLayoutOrientation.HORIZONTAL) {
                position += layoutParams._marginLeftComputed;
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
                position += layoutParams._marginTopComputed;
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
        }

        return true;
    }

    override private function refineSelfMeasure(measureWidth:Bool, measureHeight:Bool):Void {
        if (measureWidth) {
            _width = 0.0;
        }

        if (measureHeight) {
            _height = 0.0;
        }

        for (child in children) {
            var layoutParams = cast(child.layoutParams, LinearLayoutParams);

            if (measureWidth) {
                if (orientation == LinearLayoutOrientation.HORIZONTAL && layoutParams._measuredWidth < 0.0) {
                    _width = -1.0;
                    measureWidth = false;
                }

                var size = layoutParams._measuredWidth + layoutParams._marginLeftComputed + layoutParams._marginRightComputed;

                if (orientation == LinearLayoutOrientation.HORIZONTAL) {
                    _width += size;
                } else {
                    _width = Math.max(_width, size);
                }
            }

            if (measureHeight) {
                if (orientation == LinearLayoutOrientation.VERTICAL && layoutParams._measuredHeight < 0.0) {
                    _height = -1.0;
                    measureHeight = false;
                }

                var size = layoutParams._measuredHeight + layoutParams._marginTopComputed + layoutParams._marginBottomComputed;

                if (orientation == LinearLayoutOrientation.VERTICAL) {
                    _height += size;
                } else {
                    _height = Math.max(_height, size);
                }
            }
        }
    }

    override private function computeMatchParentMeasureSpec(childLayoutParams:LayoutParams, size:Float, vertical:Bool):MeasureSpec {
        var layoutParams = cast(childLayoutParams, LinearLayoutParams);

        return MeasureSpec.EXACT(size - (vertical
            ? (layoutParams._marginTopComputed + layoutParams._marginBottomComputed)
            : (layoutParams._marginLeftComputed + layoutParams._marginRightComputed)
        ));
    }

    @:noCompletion
    private function get_orientation():LinearLayoutOrientation {
        return _orientation;
    }

    @:noCompletion
    private function set_orientation(value:LinearLayoutOrientation):LinearLayoutOrientation {
        _orientation = value;
        requestLayout();
        return value;
    }
}
