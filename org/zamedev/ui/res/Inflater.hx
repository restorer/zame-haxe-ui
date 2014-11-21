package org.zamedev.ui.res;

import openfl.errors.Error;
import org.zamedev.ui.internal.ClassMapping;
import org.zamedev.ui.view.LayoutParams;
import org.zamedev.ui.view.View;
import org.zamedev.ui.view.ViewGroup;

using StringTools;

class Inflater {
    public static function parse(resourceManager:ResourceManager, resId:String, layoutParams:LayoutParams = null):View {
        return _parse(resourceManager, resId, layoutParams, new Map<String, Bool>());
    }

    public static function parseInto(resourceManager:ResourceManager, resId:String, viewGroup:ViewGroup, reLayout:Bool = true):View {
        var view = _parse(resourceManager, resId, viewGroup.createLayoutParams(), new Map<String, Bool>());
        viewGroup.addChild(view, reLayout);
        return view;
    }

    private static function _parse(
        resourceManager:ResourceManager,
        resId:String,
        layoutParams:LayoutParams,
        visitedMap:Map<String, Bool>
    ):View {
        var xmlString = resourceManager._getLayoutText(resId);
        var root = Xml.parse(xmlString).firstElement();

        if (root == null) {
            throw new Error("Parse error: " + resId);
        }

        return inflate(resourceManager, resId, layoutParams, root, visitedMap);
    }

    private static function inflate(
        resourceManager:ResourceManager,
        resId:String,
        layoutParams:LayoutParams,
        node:Xml,
        visitedMap:Map<String, Bool>
    ):View {
        var className = node.nodeName;

        if (ClassMapping.classMap.exists(className)) {
            className = ClassMapping.classMap[className];
        }

        var klass = Type.resolveClass(className);

        if (klass == null) {
            throw new Error("Parse error: " + resId + ", unknow class " + className);
        }

        var instance = Type.createInstance(klass, []);

        if (!Std.is(instance, View)) {
            throw new Error("Parse error: " + resId + ", class " + className + " is not instance of View");
        }

        var view = cast(instance, View);
        view.layoutParams = (layoutParams == null ? new LayoutParams() : layoutParams);

        var styleResId = node.get("style");

        if (styleResId != null) {
            resourceManager.getStyle(styleResId).apply(view);
        }

        for (att in node.attributes()) {
            if (att != "style") {
                if (!view.inflate(att, new TypedValue(resourceManager, node.get(att)))) {
                    throw new Error("Parse error: " + resId + ", class " + className + ", unsupported attribute " + att);
                }
            }
        }

        if (Std.is(view, ViewGroup)) {
            var viewGroup = cast(view, ViewGroup);

            for (innerNode in node.elements()) {
                viewGroup.addChild(inflate(resourceManager, resId, viewGroup.createLayoutParams(), innerNode, visitedMap));
            }
        }

        view.onInflateFinished();
        return view;
    }
}
