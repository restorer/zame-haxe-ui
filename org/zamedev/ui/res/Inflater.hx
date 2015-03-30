package org.zamedev.ui.res;

import org.zamedev.ui.Context;
import org.zamedev.ui.errors.UiError;
import org.zamedev.ui.view.LayoutParams;
import org.zamedev.ui.view.View;
import org.zamedev.ui.view.ViewGroup;

@:access(org.zamedev.ui.res.ResourceManager)
class Inflater {
    private var context:Context;

    public function new(context:Context) {
        this.context = context;
    }

    public function inflate(resId:Int, layoutParams:LayoutParams = null):View {
        var resourceManager = context.resourceManager;
        return resourceManager._getInflateFunc(resId)(layoutParams, resourceManager);
    }

    public function inflateInto(resId:Int, viewGroup:ViewGroup, reLayout:Bool = true):View {
        var resourceManager = context.resourceManager;
        var view = resourceManager._getInflateFunc(resId)(viewGroup.createLayoutParams(), resourceManager);
        viewGroup.addChild(view, reLayout);
        return view;
    }
}
