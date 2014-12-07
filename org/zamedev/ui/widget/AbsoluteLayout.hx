package org.zamedev.ui.widget;

import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.DimensionTools;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.TypedValue;
import org.zamedev.ui.view.LayoutParams;
import org.zamedev.ui.view.View;
import org.zamedev.ui.view.ViewGroup;

class AbsoluteLayout extends ViewGroup {
    @:keep
    public function new(context:Context) {
        super(context);
    }

    override public function createLayoutParams():LayoutParams {
        return new AbsoluteLayoutParams();
    }

    override private function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
        if (super.measureAndLayout(widthSpec, heightSpec)) {
            return true;
        }

        measureSelf(widthSpec, heightSpec);

        for (child in children) {
            var layoutParams = cast(child.layoutParams, AbsoluteLayoutParams);

            child.x = computeChildPosition(child, layoutParams.x, layoutParams.cx, layoutParams.ex, false);
            child.y = computeChildPosition(child, layoutParams.y, layoutParams.cy, layoutParams.ey, true);
        }

        return true;
    }

    override private function refineSelfMeasure(measureWidth:Bool, measureHeight:Bool):Void {
        for (child in children) {
            var layoutParams = child.layoutParams;

            if (measureWidth && layoutParams._measuredWidth >= 0.0) {
                _width = Math.max(_width, layoutParams._measuredWidth);
            }

            if (measureHeight && layoutParams._measuredHeight >= 0.0) {
                _height = Math.max(_height, layoutParams._measuredHeight);
            }
        }
    }

    private function computeChildPosition(child:View, startDimen:Dimension, centerParam:Dimension, endDimen:Dimension, vertical:Bool):Float {
        if (startDimen != null) {
            return computeChildDimension(child, startDimen, vertical);
        } else if (centerParam != null) {
            return computeChildDimension(child, centerParam, vertical) - (vertical ? child._height : child._width) / 2;
        } else if (endDimen != null) {
            return computeChildDimension(child, endDimen, vertical) - (vertical ? child._height : child._width);
        } else {
            return 0.0;
        }
    }
}
