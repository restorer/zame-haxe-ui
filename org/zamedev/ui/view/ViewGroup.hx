package org.zamedev.ui.view;

import openfl.errors.Error;
import openfl.events.Event;
import org.zamedev.ui.Context;
import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.DimensionType;
import org.zamedev.ui.graphics.DimensionTools;
import org.zamedev.ui.res.MeasureSpec;

class ViewGroup extends View {
    public var children:Array<View>;

    public function new(context:Context) {
        super(context);
        children = new Array<View>();

        addEventListener(Event.ADDED_TO_STAGE, onViewGroupAddedToApplicationStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onViewGroupRemovedFromApplicationStage);
    }

    public function createLayoutParams():LayoutParams {
        return new LayoutParams();
    }

    private function measureSelf(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Void {
        switch (widthSpec) {
            case MeasureSpec.UNSPECIFIED | MeasureSpec.AT_MOST(_):
                _width = -1.0;

            case MeasureSpec.EXACT(size):
                _width = size;
        }

        switch (heightSpec) {
            case MeasureSpec.UNSPECIFIED | MeasureSpec.AT_MOST(_):
                _height = -1.0;

            case MeasureSpec.EXACT(size):
                _height = size;
        }

        for (child in children) {
            var layoutParams = child.layoutParams;

            layoutParams._widthSpec = null;
            layoutParams._heightSpec = null;
            layoutParams._measured = false;
            layoutParams._measuredWidth = -1.0;
            layoutParams._measuredHeight = -1.0;
        }

        do {
            var recompute = false;
            var computed = false;

            for (child in children) {
                var layoutParams = child.layoutParams;

                if (layoutParams._measured) {
                    continue;
                }

                if (child._visibility == ViewVisibility.GONE) {
                    layoutParams._widthSpec = MeasureSpec.EXACT(0.0);
                    layoutParams._heightSpec = MeasureSpec.EXACT(0.0);

                    child.measureAndLayout(layoutParams._widthSpec, layoutParams._heightSpec);

                    layoutParams._measured = true;
                    layoutParams._measuredWidth = 0.0;
                    layoutParams._measuredHeight = 0.0;
                }

                if (layoutParams._widthSpec == null) {
                    layoutParams._widthSpec = computeChildMeasureSpec(layoutParams, layoutParams.width, false);

                    if (layoutParams._widthSpec == null) {
                        recompute = true;
                    } else {
                        switch (layoutParams._widthSpec) {
                            case MeasureSpec.EXACT(size):
                                layoutParams._measuredWidth = size;

                            default:
                                // do nothing
                        }

                        computed = true;
                    }
                }

                if (layoutParams._heightSpec == null) {
                    layoutParams._heightSpec = computeChildMeasureSpec(layoutParams, layoutParams.height, true);

                    if (layoutParams._heightSpec == null) {
                        recompute = true;
                    } else {
                        switch (layoutParams._heightSpec) {
                            case MeasureSpec.EXACT(size):
                                layoutParams._measuredHeight = size;

                            default:
                                // do nothing
                        }

                        computed = true;
                    }
                }

                if (layoutParams._widthSpec != null && layoutParams._heightSpec != null) {
                    child.measureAndLayout(layoutParams._widthSpec, layoutParams._heightSpec);

                    layoutParams._measured = true;
                    layoutParams._measuredWidth = child._width;
                    layoutParams._measuredHeight = child._height;
                }
            }

            if (!computed || !recompute) {
                break;
            }

            if (_width < 0.0 || _height < 0.0) {
                refineSelfMeasure(_width < 0.0, _height < 0.0);
            }
        } while (true);

        for (child in children) {
            var layoutParams = child.layoutParams;

            if (layoutParams._measured) {
                continue;
            }

            if (layoutParams._widthSpec == null) {
                layoutParams._widthSpec = MeasureSpec.EXACT(0.0);
            }

            if (layoutParams._heightSpec == null) {
                layoutParams._heightSpec = MeasureSpec.EXACT(0.0);
            }

            child.measureAndLayout(layoutParams._widthSpec, layoutParams._heightSpec);

            layoutParams._measured = true;
            layoutParams._measuredWidth = child._width;
            layoutParams._measuredHeight = child._height;
        }

        if (_width < 0.0 || _height < 0.0) {
            refineSelfMeasure(_width < 0.0, _height < 0.0);
        }

        switch (widthSpec) {
            case MeasureSpec.AT_MOST(size):
                _width = Math.min(_width, size);

            default:
                // do nothing
        }

        switch (heightSpec) {
            case MeasureSpec.AT_MOST(size):
                _height = Math.min(_height, size);

            default:
                // do nothing
        }
    }

    private function refineSelfMeasure(measureWidth:Bool, measureHeight:Bool):Void {
    }

    public function addChild(view:View, reLayout:Bool = true):Void {
        if (view._parent != null) {
            throw new Error("View already added to another ViewGroup");
        }

        view._parent = this;
        children.push(view);
        _sprite.addChild(view._sprite);

        if (reLayout) {
            requestLayout();
        }

        if (isAddedToApplicationStage) {
            view.dispatchEvent(new Event(Event.ADDED_TO_STAGE));
        }
    }

    public function removeChild(view:View, reLayout:Bool = true):Void {
        if (!children.remove(view)) {
            throw new Error("View is not added to this ViewGroup");
        }

        _sprite.removeChild(view._sprite);
        view._parent = null;

        if (reLayout) {
            requestLayout();
        }

        if (isAddedToApplicationStage) {
            view.dispatchEvent(new Event(Event.REMOVED_FROM_STAGE));
        }
    }

    private function onViewGroupAddedToApplicationStage(e:Event):Void {
        for (child in children) {
            child.dispatchEvent(e);
        }
    }

    private function onViewGroupRemovedFromApplicationStage(e:Event):Void {
        for (child in children) {
            child.dispatchEvent(e);
        }
    }

    public function findViewById(id:String, deep:Bool = true):View {
        for (child in children) {
            if (child.id == id) {
                return child;
            }
        }

        if (deep) {
            for (child in children) {
                if (Std.is(child, ViewGroup)) {
                    var innerChild = cast(child, ViewGroup).findViewById(id);

                    if (innerChild != null) {
                        return innerChild;
                    }
                }
            }
        }

        return null;
    }

    public function findViewsByTag(tag:String, deep:Bool = true):Array<View> {
        var result = new Array<View>();

        for (child in children) {
            if (child.tag == tag) {
                result.push(child);
            }

            if (deep && Std.is(child, ViewGroup)) {
                for (innerChild in cast(child, ViewGroup).findViewsByTag(tag)) {
                    result.push(innerChild);
                }
            }
        }

        return result;
    }

    private function computeMatchParentMeasureSpec(childLayoutParams:LayoutParams, size:Float, vertical:Bool):MeasureSpec {
        return MeasureSpec.EXACT(size);
    }

    private function computeChildMeasureSpec(layoutParams:LayoutParams, dimen:Dimension, vertical:Bool):MeasureSpec {
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

    private function computeChildDimension(child:View, dimension:Dimension, vertical:Bool):Float {
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
