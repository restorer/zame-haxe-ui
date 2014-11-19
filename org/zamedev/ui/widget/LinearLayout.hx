package org.zamedev.ui.widget;

import openfl.errors.ArgumentError;
import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.Gravity;
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
    public var orientation(default, set):LinearLayoutOrientation;

    override private function createLayoutParams():LayoutParams {
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

        var computeWidth:Bool;
        var computeHeight:Bool;

        switch (widthSpec) {
            case MeasureSpec.UNSPECIFIED | MeasureSpec.AT_MOST(_):
                _width = 0.0;
                computeWidth = true;

            case MeasureSpec.EXACT(size):
                _width = size;
                computeWidth = false;
        }

        switch (heightSpec) {
            case MeasureSpec.UNSPECIFIED | MeasureSpec.AT_MOST(_):
                _height = 0.0;
                computeHeight = true;

            case MeasureSpec.EXACT(size):
                _height = size;
                computeHeight = false;
        }

        for (child in children) {
            var layoutParams = cast(child.layoutParams, LinearLayoutParams);

            layoutParams._marginLeftComputed = computeMargin(layoutParams.marginLeft, _width, computeWidth);
            layoutParams._marginRightComputed = computeMargin(layoutParams.marginRight, _width, computeWidth);
            layoutParams._marginTopComputed = computeMargin(layoutParams.marginTop, _height, computeHeight);
            layoutParams._marginBottomComputed = computeMargin(layoutParams.marginBottom, _height, computeHeight);
        }

        if (computeWidth || computeHeight) {
            for (child in children) {
                var layoutParams = cast(child.layoutParams, LinearLayoutParams);

                child.measureAndLayout(
                    computeChildMeasureSpec(child, layoutParams.width, _width, computeWidth),
                    computeChildMeasureSpec(child, layoutParams.height, _height, computeHeight)
                );

                if (computeWidth) {
                    var size = child.width + layoutParams._marginLeftComputed + layoutParams._marginRightComputed;

                    if (orientation == LinearLayoutOrientation.HORIZONTAL) {
                        _width += size;
                    } else {
                        _width = Math.max(_width, size);
                    }
                }

                if (computeHeight) {
                    var size = child.height + layoutParams._marginTopComputed + layoutParams._marginBottomComputed;

                    if (orientation == LinearLayoutOrientation.VERTICAL) {
                        _height += size;
                    } else {
                        _height = Math.max(_height, size);
                    }
                }
            }
        }

        var position:Float = 0.0;

        for (child in children) {
            var layoutParams = cast(child.layoutParams, LinearLayoutParams);

            if (orientation == LinearLayoutOrientation.HORIZONTAL) {
                position += layoutParams._marginLeftComputed;
                child.x = position;
                position += child.width + layoutParams._marginRightComputed;

                switch (layoutParams.gravity) {
                    case Gravity.BOTTOM | Gravity.END:
                        child.ey = _height;

                    case Gravity.CENTER | Gravity.CENTER_VERTICAL:
                        child.cy = _height / 2;

                    default:
                        child.y = 0;
                }
            } else {
                position += layoutParams._marginTopComputed;
                child.x = position;
                position += child.height + layoutParams._marginBottomComputed;

                switch (layoutParams.gravity) {
                    case Gravity.RIGHT | Gravity.END:
                        child.ex = _width;

                    case Gravity.CENTER | Gravity.CENTER_HORIZONTAL:
                        child.cx = _width / 2;

                    default:
                        child.x = 0;
                }
            }
        }

        return true;
    }

    private function computeMargin(dimen:Dimension, layoutSize:Float, computeSize:Bool):Float {
        return switch(dimen) {
            case Dimension.EXACT(size):
                size;

            case Dimension.PERCENT(weight) | Dimension.WEIGHT(weight):
                (computeSize ? 0.0 : layoutSize * weight);

            case Dimension.MATCH_PARENT:
                (computeSize ? 0.0 : layoutSize);

            case Dimension.WRAP_CONTENT:
                0.0;
        };
    }

    private function computeChildMeasureSpec(child:View, dimen:Dimension, layoutSize:Float, computeSize:Bool):MeasureSpec {
        return switch(dimen) {
            case Dimension.WRAP_CONTENT:
                (computeSize ? MeasureSpec.UNSPECIFIED : MeasureSpec.AT_MOST(layoutSize));

            case Dimension.MATCH_PARENT:
                (computeSize ? MeasureSpec.UNSPECIFIED : MeasureSpec.EXACT(layoutSize));

            case Dimension.EXACT(size):
                MeasureSpec.AT_MOST(Math.min(layoutSize, size));

            case Dimension.PERCENT(weight) | Dimension.WEIGHT(weight):
                (computeSize ? MeasureSpec.UNSPECIFIED : MeasureSpec.AT_MOST(Math.min(layoutSize, layoutSize * weight)));
        };
    }

    @:noCompletion
    private function set_orientation(value:LinearLayoutOrientation):LinearLayoutOrientation {
        orientation = value;
        requestLayout();
        return value;
    }
}
