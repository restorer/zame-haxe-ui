package org.zamedev.ui.view;

import openfl.errors.Error;
import org.zamedev.ui.res.MeasureSpec;

class ViewGroup extends View {
    public var children:Array<View>;

    public function new() {
        super();
        children = new Array<View>();
    }

    public function createLayoutParams():LayoutParams {
        return new LayoutParams();
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
    }

    public function findChildById(id:String, deep:Bool = true):View {
        for (child in children) {
            if (child.id == id) {
                return child;
            }
        }

        if (deep) {
            for (child in children) {
                if (Std.is(child, ViewGroup)) {
                    var innerChild = cast(child, ViewGroup).findChildById(id);

                    if (innerChild != null) {
                        return innerChild;
                    }
                }
            }
        }

        return null;
    }

    public function findChildrenByTag(tag:String, deep:Bool = true):Array<View> {
        var result = new Array<View>();

        for (child in children) {
            if (child.tag == tag) {
                result.push(child);
            }

            if (deep && Std.is(child, ViewGroup)) {
                for (innerChild in cast(child, ViewGroup).findChildrenByTag(tag)) {
                    result.push(innerChild);
                }
            }
        }

        return result;
    }
}
