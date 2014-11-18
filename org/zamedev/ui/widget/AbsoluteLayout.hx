package org.zamedev.ui.widget;

import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.DimensionTools;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.view.LayoutParams;
import org.zamedev.ui.view.View;
import org.zamedev.ui.view.ViewGroup;

class AbsoluteLayout extends ViewGroup {
    override private function createLayoutParams():LayoutParams {
        return new AbsoluteLayoutParams();
    }

    override public function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
        if (super.measureAndLayout(widthSpec, heightSpec)) {
            return true;
        }

        switch (widthSpec) {
            case MeasureSpec.UNSPECIFIED:
                _width = 0.0;

            case MeasureSpec.EXACT(size) | MeasureSpec.AT_MOST(size):
                _width = size;
        }

        switch (heightSpec) {
            case MeasureSpec.UNSPECIFIED:
                _height = 0.0;

            case MeasureSpec.EXACT(size) | MeasureSpec.AT_MOST(size):
                _height = size;
        }

        for (child in children) {
            var layoutParams = cast(child.layoutParams, AbsoluteLayoutParams);

            child.measureAndLayout(
                computeChildMeasureSpec(child, layoutParams.width, _width),
                computeChildMeasureSpec(child, layoutParams.height, _height)
            );

            child.x = computeChildPosition(child, layoutParams.x, layoutParams.cx, layoutParams.ex, child.width, _width);
            child.y = computeChildPosition(child, layoutParams.y, layoutParams.cy, layoutParams.ey, child.height, _height);
        }

        return true;
    }

    private function computeChildMeasureSpec(child:View, dimen:Dimension, layoutSize:Float):MeasureSpec {
        return switch(dimen) {
            case Dimension.WRAP_CONTENT:
                MeasureSpec.AT_MOST(layoutSize);

            case Dimension.MATCH_PARENT:
                MeasureSpec.EXACT(layoutSize);

            case Dimension.EXACT(size):
                MeasureSpec.AT_MOST(Math.min(layoutSize, size));

            case Dimension.WEIGHT(weight):
                MeasureSpec.AT_MOST(Math.min(layoutSize, layoutSize * weight));
        };
    }

    private function computeChildPosition(
        child:View,
        startDimen:Dimension,
        centerParam:Dimension,
        endDimen:Dimension,
        childSize:Float,
        layoutSize:Float
    ):Float {
        if (startDimen != null) {
            return DimensionTools.resolve(startDimen, childSize, layoutSize);
        } else if (centerParam != null) {
            return DimensionTools.resolve(centerParam, childSize, layoutSize) - childSize / 2;
        } else if (endDimen != null) {
            return DimensionTools.resolve(endDimen, childSize, layoutSize) - childSize;
        } else {
            return 0.0;
        }
    }
}
