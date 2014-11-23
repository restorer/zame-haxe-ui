package org.zamedev.ui.res;

import openfl.errors.Error;
import org.zamedev.ui.Context;
import org.zamedev.ui.internal.ClassMapping;
import org.zamedev.ui.view.LayoutParams;
import org.zamedev.ui.view.View;
import org.zamedev.ui.view.ViewGroup;

using StringTools;

class Inflater {
    private var context:Context;

    public function new(context:Context) {
        this.context = context;
    }

    public function inflate(resId:String, layoutParams:LayoutParams = null):View {
        return _inflateResource(resId, layoutParams, new Map<String, Bool>());
    }

    public function inflateInto(resId:String, viewGroup:ViewGroup, reLayout:Bool = true):View {
        var view = _inflateResource(resId, viewGroup.createLayoutParams(), new Map<String, Bool>());
        viewGroup.addChild(view, reLayout);
        return view;
    }

    private function _inflateResource(resId:String, layoutParams:LayoutParams, visitedMap:Map<String, Bool>):View {
        var xmlString = context.resourceManager._getLayoutText(resId);
        var root = Xml.parse(xmlString).firstElement();

        if (root == null) {
            throw new Error("Parse error: " + resId);
        }

        return _inflateNode(resId, layoutParams, root, visitedMap);
    }

    private function _inflateNode(resId:String, layoutParams:LayoutParams, node:Xml, visitedMap:Map<String, Bool>):View {
        var className = node.nodeName;

        if (ClassMapping.classMap.exists(className)) {
            className = ClassMapping.classMap[className];
        }

        var klass = Type.resolveClass(className);

        if (klass == null) {
            throw new Error("Parse error: " + resId + ", unknow class " + className);
        }

        var instance = Type.createInstance(klass, [context]);

        if (!Std.is(instance, View)) {
            throw new Error("Parse error: " + resId + ", class " + className + " is not instance of View");
        }

        var view = cast(instance, View);
        view.onInflateStarted();
        view.layoutParams = (layoutParams == null ? new LayoutParams() : layoutParams);

        var styleResId = node.get("style");

        if (styleResId != null) {
            context.resourceManager.getStyle(styleResId).apply(view);
        }

        for (att in node.attributes()) {
            if (att != "style") {
                if (!view.inflate(att, new TypedValue(context.resourceManager, node.get(att)))) {
                    throw new Error("Parse error: " + resId + ", class " + className + ", unsupported attribute " + att);
                }
            }
        }

        if (Std.is(view, ViewGroup)) {
            var viewGroup = cast(view, ViewGroup);

            for (innerNode in node.elements()) {
                viewGroup.addChild(_inflateNode(resId, viewGroup.createLayoutParams(), innerNode, visitedMap));
            }
        }

        view.onInflateFinished();
        return view;
    }
}
