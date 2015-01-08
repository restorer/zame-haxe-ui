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
        return _inflateResource(resId, layoutParams, new Map<String, Bool>(), new Map<String, String>());
    }

    public function inflateInto(resId:String, viewGroup:ViewGroup, reLayout:Bool = true):View {
        var view = _inflateResource(resId, viewGroup.createLayoutParams(), new Map<String, Bool>(), new Map<String, String>());
        viewGroup.addChild(view, reLayout);
        return view;
    }

    private function _inflateResource(resId:String, layoutParams:LayoutParams, visitedMap:Map<String, Bool>, vars:Map<String, String>):View {
        var xmlString = context.resourceManager._getLayoutText(resId);
        var root = Xml.parse(xmlString).firstElement();

        if (root == null) {
            throw new Error("Parse error: " + resId);
        }

        return _inflateNode(resId, layoutParams, root, visitedMap, vars);
    }

    private function _inflateNode(resId:String, layoutParams:LayoutParams, node:Xml, visitedMap:Map<String, Bool>, vars:Map<String, String>):View {
        visitedMap[resId] = true;
        var className = node.nodeName;

        if (className == "include") {
            var includeResId = node.get("layout");

            if (includeResId == null) {
                throw new Error("Parse error: " + resId + ", layout is not specified in include tag");
            } else if (visitedMap.exists(includeResId)) {
                throw new Error("Parse error: " + resId + ", circular dependency on " + includeResId);
            }

            var newVars = new Map<String, String>();

            for (att in node.attributes()) {
                if (att == "layout") {
                    continue;
                } else if (att.substr(0, 4) != "var_") {
                    throw new Error("Parse error: " + resId + ", unsupported attribute " + att + " in include tag");
                }

                var value = node.get(att);

                if (value.substr(0, 5) == "@var/") {
                    var value = vars[value.substr(5)];

                    if (value == null) {
                        throw new Error("Parse error: " + resId + ", " + node.get(att) + " not found for attribute " + att + " in include tag");
                    }
                }

                newVars[att.substr(4)] = value;
            }

            var newVisitedMap = new Map<String, Bool>();

            for (key in visitedMap.keys()) {
                newVisitedMap[key] = visitedMap[key];
            }

            return _inflateResource(includeResId, layoutParams, newVisitedMap, newVars);
        }

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
            if (att == "style") {
                continue;
            }

            var value = node.get(att);

            if (value.substr(0, 5) == "@var/") {
                value = vars[value.substr(5)];

                if (value == null) {
                    throw new Error("Parse error: " + resId + ", class " + className + ", " + node.get(att) + " not found for attribute " + att);
                }
            }

            if (!view.inflate(att, new TypedValue(context.resourceManager, value))) {
                throw new Error("Parse error: " + resId + ", class " + className + ", unsupported attribute " + att);
            }
        }

        if (Std.is(view, ViewGroup)) {
            var viewGroup = cast(view, ViewGroup);

            for (innerNode in node.elements()) {
                viewGroup.addChild(_inflateNode(resId, viewGroup.createLayoutParams(), innerNode, visitedMap, vars), false);
            }
        }

        view.onInflateFinished();
        return view;
    }
}
