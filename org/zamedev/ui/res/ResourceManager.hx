package org.zamedev.ui.res;

import openfl.Assets;
import openfl.errors.Error;
import org.zamedev.ui.graphics.Color;
import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.DimensionTools;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.internal.XmlExt;
import org.zamedev.ui.view.View;

using StringTools;

typedef StyleSpec = {
    name:String,
    includeList:Array<String>,
    itemMap:Map<String, String>,
};

class ResourceManager {
    private var context:Context;
    private var colors:Map<String, UInt>;
    private var fonts:Map<String, String>;
    private var dimensions:Map<String, Dimension>;
    private var drawables:Map<String, Drawable>;
    private var strings:Map<String, String>;
    private var styles:Map<String, Map<String, TypedValue>>;

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
        if (~/^\s*@selector\/([a-zA-Z0-9_]+)\s*$/.match(id)) {
            return Selector.parse(this, id);
        } else {
            return Selector.parse(this, "@selector/" + id);
        }
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

    public function getStyle(id:String):Map<String, TypedValue> {
        var value = styles[id];

        if (value == null) {
            value = styles["@style/" + id];

            if (value == null) {
                throw new Error("Style not found: " + id);
            }
        }

        return value;
    }

    public function inflateLayout(id:String):View {
        if (~/^\s*@layout\/([a-zA-Z0-9_]+)\s*$/.match(id)) {
            return Inflater.parse(this, id);
        } else {
            return Inflater.parse(this, "@layout/" + id);
        }
    }

    public function _getSelectorText(id:String):String {
        var re = ~/^\s*@selector\/([a-zA-Z0-9_]+)\s*$/;

        if (!re.match(id)) {
            throw new Error("Selector not found: " + id);
        }

        var assetId = "selector/" + re.matched(1) + ".xml";

        if (!Assets.exists(assetId, AssetType.TEXT)) {
            throw new Error("Selector not found: " + id);
        }

        return Assets.getText(assetId);
    }

    public function _getLayoutText(id:String):String {
        var re = ~/^\s*@layout\/([a-zA-Z0-9_]+)\s*$/;

        if (!re.match(id)) {
            throw new Error("Layout not found: " + id);
        }

        var assetId = "layout/" + re.matched(1) + ".xml";

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
        styles = new Map<String, Map<String, TypedValue>>();

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

        for (assetId in Assets.list(AssetType.TEXT)) {
            if (~/^resource(?:\-[a-zA-Z0-9]+)?\/.+\.xml$/.match(assetId)) {
                parseResourceXml(Assets.getText(assetId), styleSpecMap);
            }
        }

        for (name in styleSpecMap.keys()) {
            styles["@style/" + name] = resolveStyle(styleSpecMap, styleSpecMap[name]);
        }
    }

    private function parseResourceXml(xmlString:String, styleSpecMap:Map<String, StyleSpec>):Void {
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
                    colors["@color/" + name] = Color.parse(XmlExt.getNodeValue(resolved));

                case "dimen":
                    dimensions["@dimen/" + name] = DimensionTools.parse(XmlExt.getNodeValue(resolved));

                case "font":
                    fonts["@font/" + name] = Assets.getFont("font/" + XmlExt.getNodeValue(resolved).trim()).fontName;

                case "string":
                    strings["@string/" + name] = XmlExt.getNodeValue(resolved);

                case "style": {
                    var styleSpec = {
                        name: "@style/" + name,
                        includeList: new Array<String>(),
                        itemMap: new Map<String, String>(),
                    };

                    for (innerNode in node.elements()) {
                        var innerName = innerNode.get("name");

                        if (innerName == null || innerName == "") {
                            throw new Error("Parse error: @style/" + name);
                        }

                        switch (innerNode.nodeName) {
                            case "include":
                                styleSpec.includeList.push(innerName);

                            case "item": {
                                var innerValue = innerNode.get("value");

                                if (innerValue == null) {
                                    throw new Error("Parse error: @style/" + name);
                                }

                                styleSpec.itemMap[innerName] = innerValue;
                            }

                            default:
                                throw new Error("Parse error: @style/" + name);
                        }
                    }

                    styleSpecMap["@style/" + name] = styleSpec;
                }

                default:
                    throw new Error("Unknown resource type: " + node.nodeName);
            }
        }
    }

    private static function resolveResourceValue(resourceMap:Map<String, Xml>, node:Xml, visitedMap:Map<String, Bool> = null):Xml {
        var re = ~/^\s*@([a-z]+\/[a-zA-Z0-9_]+)\s*$/;

        if (!re.match(XmlExt.getNodeValue(node))) {
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

        var re = ~/^\s*@([a-z]+)\/[a-zA-Z0-9_]+\s*$/;

        for (name in styleSpec.itemMap.keys()) {
            var value = styleSpec.itemMap[name];

            if (re.match(value)) {
                var resourceType = re.matched(1);

                if (resourceType != "color"
                    && resourceType != "dimen"
                    && resourceType != "font"
                    && resourceType != "string"
                ) {
                    throw new Error("Unsupported styled resource type reference in: " + styleSpec.name);
                }
            }

            resolvedStyle[name] = new TypedValue(this, value);
        }

        return resolvedStyle;
    }
}
