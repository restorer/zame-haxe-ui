package org.zamedev.ui.widget;

import org.zamedev.ui.graphics.GravityType;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.view.LayoutParams;
import org.zamedev.ui.view.ViewGroup;
import org.zamedev.ui.view.ViewVisibility;

class FrameLayout extends ViewGroup {
    override public function createLayoutParams():LayoutParams {
        return new FrameLayoutParams();
    }

    override private function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
        if (super.measureAndLayout(widthSpec, heightSpec)) {
            return true;
        }

        for (child in children) {
            var layoutParams = cast(child.layoutParams, FrameLayoutParams);

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

        for (child in children) {
            var layoutParams = cast(child.layoutParams, FrameLayoutParams);

            switch (layoutParams.gravity.horizontalType) {
                case GravityType.END:
                    child.ex = _width - layoutParams._marginRightComputed;

                case GravityType.CENTER:
                    child.cx = _width / 2;

                default:
                    child.x = layoutParams._marginLeftComputed;
            }

            switch (layoutParams.gravity.verticalType) {
                case GravityType.END:
                    child.ey = _height - layoutParams._marginBottomComputed;

                case GravityType.CENTER:
                    child.cy = _height / 2;

                default:
                    child.y = layoutParams._marginTopComputed;
            }
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

    override private function computeMatchParentMeasureSpec(childLayoutParams:LayoutParams, size:Float, vertical:Bool):MeasureSpec {
        var layoutParams = cast(childLayoutParams, FrameLayoutParams);

        return MeasureSpec.EXACT(size - (vertical
            ? (layoutParams._marginTopComputed + layoutParams._marginBottomComputed)
            : (layoutParams._marginLeftComputed + layoutParams._marginRightComputed)
        ));
    }
}
