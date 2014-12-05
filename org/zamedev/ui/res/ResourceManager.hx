package org.zamedev.ui.res;

import openfl.Assets;
import openfl.errors.Error;
import org.zamedev.ui.graphics.Color;
import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.DimensionTools;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.view.LayoutParams;
import org.zamedev.ui.view.View;
import org.zamedev.ui.view.ViewGroup;

using StringTools;
using org.zamedev.lib.XmlExt;

typedef StyleSpec = {
    name:String,
    includeList:Array<String>,
    itemMap:Map<String, TypedValue>,
};

typedef SelectorSpec = {
    name:String,
    includeList:Array<String>,
    paramMap:Map<String, Array<Selector.SelectorItem>>,
};

class ResourceManager {
    private var context:Context;
    private var colors:Map<String, UInt>;
    private var fonts:Map<String, String>;
    private var dimensions:Map<String, Dimension>;
    private var drawables:Map<String, Drawable>;
    private var strings:Map<String, String>;
    private var styles:Map<String, Style>;
    private var selectors:Map<String, Selector>;

    public function new(context:Context) {
        this.context = context;
        reload();
    }

    public function getColor(id:String):UInt {
        if (colors.exists(id)) {
            return colors[id];
        }

        if (colors.exists("@color/" + id)) {
            return colors["@color/" + id];
        }

        throw new Error("Color not found: " + id);
    }

    public function getDimension(id:String):Dimension {
        var value = dimensions[id];

        if (value == null) {
            value = dimensions["@dimen/" + id];

            if (value == null) {
                throw new Error("Dimension not found: " + id);
            }
        }

        return value;
    }

    public function getDrawable(id:String):Drawable {
        if (id == "null" || id == "@drawable/null") {
            return null;
        }

        var value = drawables[id];

        if (value == null) {
            value = drawables["@drawable/" + id];

            if (value == null) {
                throw new Error("Drawable not found: " + id);
            }
        }

        return value;
    }

    public function getFont(id:String):String {
        var value = fonts[id];

        if (value == null) {
            value = fonts["@font/" + id];

            if (value == null) {
                throw new Error("Font not found: " + id);
            }
        }

        return value;
    }

    public function getSelector(id:String):Selector {
        var value = selectors[id];

        if (value == null) {
            value = selectors["@selector/" + id];

            if (value == null) {
                throw new Error("Selector not found: " + id);
            }
        }

        return value;
    }

    public function getString(id:String):String {
        var value = strings[id];

        if (value == null) {
            value = strings["@string/" + id];

            if (value == null) {
                throw new Error("String not found: " + id);
            }
        }

        return value;
    }

    public function getStyle(id:String):Style {
        var value = styles[id];

        if (value == null) {
            value = styles["@style/" + id];

            if (value == null) {
                throw new Error("Style not found: " + id);
            }
        }

        return value;
    }

    public function _getLayoutText(id:String):String {
        var re = ~/^\s*@layout\/([a-zA-Z0-9_]+)\s*$/;
        var assetId = "layout/" + (re.match(id) ? re.matched(1) : id) + ".xml";

        if (!Assets.exists(assetId, AssetType.TEXT)) {
            throw new Error("Layout not found: " + id);
        }

        return Assets.getText(assetId);
    }

    public function reload() {
        colors = new Map<String, UInt>();
        dimensions = new Map<String, Dimension>();
        drawables = new Map<String, Drawable>();
        fonts = new Map<String, String>();
        strings = new Map<String, String>();
        styles = new Map<String, Style>();
        selectors = new Map<String, Selector>();

        for (assetId in Assets.list(AssetType.IMAGE)) {
            var re = ~/^drawable(?:\-[a-zA-Z0-9]+)?\/([a-zA-Z0-9_]+)\.([a-z]+)$/;

            if (re.match(assetId)) {
                var ext = re.matched(2).toLowerCase();

                if (ext == "png" || ext == "jpg" || ext == "jpeg" || ext == "gif") {
                    drawables["@drawable/" + re.matched(1)] = new Drawable(DrawableType.BITMAP, assetId);
                }
            }
        }

        var styleSpecMap = new Map<String, StyleSpec>();
        var selectorSpecMap = new Map<String, SelectorSpec>();

        for (assetId in Assets.list(AssetType.TEXT)) {
            var re = ~/^([a-z]+)(?:\-[a-zA-Z0-9]+)?\/(.+)\.xml$/;

            if (re.match(assetId) && re.matched(1) == "resource") {
                parseResourceXml(Assets.getText(assetId), styleSpecMap, selectorSpecMap);
            }
        }

        for (name in styleSpecMap.keys()) {
            styles["@style/" + name] = new Style(resolveStyle(styleSpecMap, styleSpecMap[name]));
        }

        for (name in selectorSpecMap.keys()) {
            selectors["@selector/" + name] = new Selector(resolveSelector(selectorSpecMap, selectorSpecMap[name]));
        }
    }

    private function parseResourceXml(xmlString:String, styleSpecMap:Map<String, StyleSpec>, selectorSpecMap:Map<String, SelectorSpec>):Void {
        var root = Xml.parse(xmlString).elementsNamed("resources").next();

        if (root == null) {
            return;
        }

        var resourceMap = new Map<String, Xml>();

        for (node in root.elements()) {
            var name = node.get("name");

            if (name != null) {
                resourceMap[node.nodeName + "/" + name] = node;
            }
        }

        for (node in resourceMap) {
            var resolved = resolveResourceValue(resourceMap, node);
            var name = node.get("name");

            switch (node.nodeName) {
                case "color":
                    colors["@color/" + name] = Color.parse(resolved.innerText());

                case "dimen":
                    dimensions["@dimen/" + name] = DimensionTools.parse(resolved.innerText());

                case "font":
                    fonts["@font/" + name] = Assets.getFont("font/" + resolved.innerText().trim()).fontName;

                case "string":
                    strings["@string/" + name] = TypedValue.processRawString(resolved.innerText());

                case "style": {
                    var styleSpec = {
                        name: "@style/" + name,
                        includeList: new Array<String>(),
                        itemMap: new Map<String, TypedValue>(),
                    };

                    for (innerNode in node.elements()) {
                        var innerName = innerNode.get("name");

                        if (innerName == null || innerName == "") {
                            throw new Error("Parse error: " + styleSpec.name);
                        }

                        switch (innerNode.nodeName) {
                            case "include":
                                styleSpec.includeList.push(innerName);

                            case "item":
                                styleSpec.itemMap[innerName] = new TypedValue(this, innerNode.innerText());

                            default:
                                throw new Error("Parse error: " + styleSpec.name);
                        }
                    }

                    styleSpecMap[styleSpec.name] = styleSpec;
                }

                case "selector": {
                    var selectorSpec = {
                        name: "@selector/" + name,
                        includeList: new Array<String>(),
                        paramMap: new Map<String, Array<Selector.SelectorItem>>(),
                    };

                    for (innerNode in node.elements()) {
                        var innerName = innerNode.get("name");

                        if (innerName == null || innerName == "") {
                            throw new Error("Parse error: " + selectorSpec.name);
                        }

                        switch (innerNode.nodeName) {
                            case "include":
                                selectorSpec.includeList.push(innerName);

                            case "param": {
                                selectorSpec.paramMap[innerName] = new Array<Selector.SelectorItem>();

                                for (stateNode in innerNode.elements()) {
                                    if (stateNode.nodeName != "state") {
                                        throw new Error("Parse error: " + selectorSpec.name);
                                    }

                                    var selectorItem = {
                                        stateMap: new Map<String, Bool>(),
                                        value: new TypedValue(this, stateNode.innerText()),
                                    };

                                    for (att in stateNode.attributes()) {
                                        selectorItem.stateMap[att] = (stateNode.get(att).trim().toLowerCase() == "true");
                                    }

                                    selectorSpec.paramMap[innerName].push(selectorItem);
                                }
                            }

                            default:
                                throw new Error("Parse error: " + selectorSpec.name);
                        }
                    }

                    selectorSpecMap[selectorSpec.name] = selectorSpec;
                }

                default:
                    throw new Error("Unknown resource type: " + node.nodeName);
            }
        }
    }

    private static function resolveResourceValue(resourceMap:Map<String, Xml>, node:Xml, visitedMap:Map<String, Bool> = null):Xml {
        var re = ~/^\s*@([a-z]+\/[a-zA-Z0-9_]+)\s*$/;

        if (!re.match(node.innerText())) {
            return node;
        }

        var referenceKey = re.matched(1);

        if (visitedMap == null) {
            visitedMap = new Map<String, Bool>();
        } else if (visitedMap.exists(referenceKey)) {
            throw new Error("Circular dependency: @" + referenceKey);
        }

        if (!resourceMap.exists(referenceKey)) {
            throw new Error("Reference not found: @" + referenceKey);
        }

        visitedMap[node.nodeName + "/" + node.get("name")] = true;
        return resolveResourceValue(resourceMap, resourceMap.get(referenceKey), visitedMap);
    }

    private function resolveStyle(
        styleSpecMap:Map<String, StyleSpec>,
        styleSpec:StyleSpec,
        visitedMap:Map<String, Bool> = null
    ):Map<String, TypedValue> {
        var resolvedStyle = new Map<String, TypedValue>();

        if (visitedMap == null) {
            visitedMap = new Map<String, Bool>();
        }

        visitedMap[styleSpec.name] = true;

        for (includeName in styleSpec.includeList) {
            if (visitedMap.exists(includeName)) {
                continue;
            }

            var includeSpec = styleSpecMap[includeName];

            if (includeSpec == null) {
                throw new Error("Included style not found in: " + styleSpec.name);
            }

            var includeMap = resolveStyle(styleSpecMap, includeSpec, visitedMap);

            for (name in includeMap.keys()) {
                resolvedStyle[name] = includeMap[name];
            }
        }

        for (name in styleSpec.itemMap.keys()) {
            resolvedStyle[name] = styleSpec.itemMap[name];
        }

        return resolvedStyle;
    }

    private function resolveSelector(
        selectorSpecMap:Map<String, SelectorSpec>,
        selectorSpec:SelectorSpec,
        visitedMap:Map<String, Bool> = null
    ):Map<String, Array<Selector.SelectorItem>> {
        var resolvedSelector = new Map<String, Array<Selector.SelectorItem>>();

        if (visitedMap == null) {
            visitedMap = new Map<String, Bool>();
        }

        visitedMap[selectorSpec.name] = true;

        for (includeName in selectorSpec.includeList) {
            if (visitedMap.exists(includeName)) {
                continue;
            }

            var includeSpec = selectorSpecMap[includeName];

            if (includeSpec == null) {
                throw new Error("Included selector not found in: " + selectorSpec.name);
            }

            var includeMap = resolveSelector(selectorSpecMap, includeSpec, visitedMap);

            for (name in includeMap.keys()) {
                resolvedSelector[name] = includeMap[name];
            }
        }

        for (name in selectorSpec.paramMap.keys()) {
            resolvedSelector[name] = selectorSpec.paramMap[name];
        }

        return resolvedSelector;
    }
}
