package org.zamedev.ui.view;

import openfl.errors.Error;
import openfl.events.Event;
import org.zamedev.ui.Context;
import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.DimensionType;
import org.zamedev.ui.graphics.DimensionTools;
import org.zamedev.ui.res.MeasureSpec;

using Lambda;

class ViewGroup extends ViewContainer {
    @:keep
    public function new(context:Context) {
        super(context);
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

                    child.selfLayout(layoutParams._widthSpec, layoutParams._heightSpec);

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
                    child.selfLayout(layoutParams._widthSpec, layoutParams._heightSpec);

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

            child.selfLayout(layoutParams._widthSpec, layoutParams._heightSpec);

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
        _addChild(view, reLayout);
    }

    public function removeChild(view:View, reLayout:Bool = true):Void {
        _removeChild(view, reLayout);
    }

    public function removeAllChildren(reLayout:Bool = true):Void {
        for (child in children.copy()) {
            removeChild(child, false);
        }

        if (reLayout) {
            requestLayout();
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
            var tagValue = child.tags[tag];

            if (tagValue != null) {
                if (!Std.is(tagValue, Bool)) {
                    result.push(child);
                } else {
                    var boolValue:Bool = cast tagValue;

                    if (boolValue) {
                        result.push(child);
                    }
                }
            }

            if (deep && Std.is(child, ViewGroup)) {
                for (innerChild in cast(child, ViewGroup).findViewsByTag(tag)) {
                    result.push(innerChild);
                }
            }
        }

        return result;
    }
}
