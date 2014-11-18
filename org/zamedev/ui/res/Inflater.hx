package org.zamedev.ui.res;

import openfl.errors.Error;
import org.zamedev.ui.internal.ClassMapping;
import org.zamedev.ui.view.View;
import org.zamedev.ui.view.ViewGroup;

using StringTools;

class Inflater {
    public static function parse(resourceManager:ResourceManager, resId:String):View {
        return _parse(resourceManager, resId, new Map<String, Bool>());
    }

    private static function _parse(
        resourceManager:ResourceManager,
        resId:String,
        visitedMap:Map<String, Bool>
    ):View {
        var xmlString = resourceManager._getLayoutText(resId);
        var root = Xml.parse(xmlString).firstElement();

        if (root == null) {
            throw new Error("Parse error: " + resId);
        }

        return inflate(resourceManager, resId, root, visitedMap);
    }

    private static function inflate(
        resourceManager:ResourceManager,
        resId:String,
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
        var styleResId = node.get("style");

        if (styleResId != null) {
            var styleMap = resourceManager.getStyle(styleResId);

            for (key in styleMap.keys()) {
                if (!view.inflate(key, styleMap[key])) {
                    throw new Error("Parse error: " + resId + ", class " + className + ", unsupported attribute " + key);
                }
            }
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
                viewGroup.addChild(inflate(resourceManager, resId, innerNode, visitedMap));
            }
        }

        return view;
    }
}
