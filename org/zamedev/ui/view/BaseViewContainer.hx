package org.zamedev.ui.view;

import org.zamedev.ui.Context;
import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.DimensionTools;
import org.zamedev.ui.graphics.DimensionType;
import org.zamedev.ui.res.MeasureSpec;

class BaseViewContainer extends View {
    @:keep
    public function new(context : Context) {
        super(context);
    }

    private function computeMatchParentMeasureSpec(childLayoutParams : LayoutParams, size : Float, vertical : Bool) : MeasureSpec {
        return MeasureSpec.EXACT(size);
    }

    private function computeChildMeasureSpec(layoutParams : LayoutParams, dimen : Dimension, vertical : Bool) : MeasureSpec {
        switch (dimen) {
            case Dimension.WRAP_CONTENT:
                return MeasureSpec.UNSPECIFIED;

            case Dimension.MATCH_PARENT:
                if (vertical) {
                    return (_height >= 0.0 ? computeMatchParentMeasureSpec(layoutParams, _height, vertical) : null);
                } else {
                    return (_width >= 0.0 ? computeMatchParentMeasureSpec(layoutParams, _width, vertical) : null);
                }

            case Dimension.EXACT(size):
                return MeasureSpec.EXACT(size);

            case Dimension.WEIGHT_PARENT(weight, type, useWeightSum): {
                if ((type == DimensionType.MIN || type == DimensionType.MAX) && (_height < 0.0 || _width < 0.0)) {
                    return null;
                }

                if (DimensionTools.resolveVertical(_width, _height, type, vertical)) {
                    return (_height >= 0.0
                        ? MeasureSpec.EXACT(DimensionTools.resolveWeight(weight, _height, heightWeightSum, useWeightSum))
                        : null
                    );
                } else {
                    return (_width >= 0.0
                        ? MeasureSpec.EXACT(DimensionTools.resolveWeight(weight, _width, widthWeightSum, useWeightSum))
                        : null
                    );
                }
            }

            case Dimension.WEIGHT_STAGE(weight, type, useWeightSum): {
                var appStage = _context.applicationStage;

                if (DimensionTools.resolveVertical(appStage.width, appStage.height, type, vertical)) {
                    return MeasureSpec.EXACT(DimensionTools.resolveWeight(weight, appStage.height, appStage.heightWeightSum, useWeightSum));
                } else {
                    return MeasureSpec.EXACT(DimensionTools.resolveWeight(weight, appStage.width, appStage.widthWeightSum, useWeightSum));
                }
            }
        }
    }

    private function computeChildDimension(child : View, dimension : Dimension, vertical : Bool) : Float {
        switch (dimension) {
            case Dimension.WRAP_CONTENT:
                return (vertical ? child._height : child._width);

            case Dimension.MATCH_PARENT:
                return (vertical ? _height : _width);

            case Dimension.EXACT(size):
                return size;

            case Dimension.WEIGHT_PARENT(weight, type, useWeightSum):
                if (DimensionTools.resolveVertical(_width, _height, type, vertical)) {
                    return DimensionTools.resolveWeight(weight, _height, heightWeightSum, useWeightSum);
                } else {
                    return DimensionTools.resolveWeight(weight, _width, widthWeightSum, useWeightSum);
                }

            case Dimension.WEIGHT_STAGE(weight, type, useWeightSum): {
                var appStage = _context.applicationStage;

                if (DimensionTools.resolveVertical(appStage.width, appStage.height, type, vertical)) {
                    return DimensionTools.resolveWeight(weight, appStage.height, appStage.heightWeightSum, useWeightSum);
                } else {
                    return DimensionTools.resolveWeight(weight, appStage.width, appStage.widthWeightSum, useWeightSum);
                }
            }
        }
    }
}
