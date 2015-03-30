package org.zamedev.ui.tools;

import org.zamedev.lib.ds.LinkedMap;
import org.zamedev.ui.errors.UiParseError;
import org.zamedev.ui.graphics.Color;
import org.zamedev.ui.graphics.DimensionTools;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.graphics.DrawableType;
import org.zamedev.ui.tools.generator.GenFont;
import org.zamedev.ui.tools.parser.ParseHelper;
import org.zamedev.ui.tools.parser.SelectorParser;
import org.zamedev.ui.tools.parser.StyleParser;

using StringTools;
using org.zamedev.lib.LambdaExt;
using org.zamedev.lib.XmlExt;

class ResParser {
    private var resourceMap:LinkedMap<String, Xml>;

    public function new():Void {
        resourceMap = new LinkedMap<String, Xml>();
    }

    public function tryParse(xmlString:String):Bool {
        var root = Xml.parse(xmlString).elementsNamed("resources").next();

        if (root == null) {
            return false;
        }

        for (node in root.elements()) {
            var name = node.get("name");

            if (name != null) {
                resourceMap[node.nodeName + "/" + name] = node;
            }
        }

        return true;
    }

    public function toGenerator(resGenerator:ResGenerator):Void {
        var styleParser = new StyleParser();
        var selectorParser = new SelectorParser();

        for (node in resourceMap) {
            var resolved = resolveResourceValue(node);
            var name = node.get("name");

            switch (node.nodeName) {
                case "color":
                    resGenerator.putColor(name, Color.parse(resolved.innerText()));

                case "dimen":
                    resGenerator.putDimen(name, DimensionTools.parse(resolved.innerText()));

                case "string":
                    resGenerator.putString(name, parseString(resolved.innerText()));

                case "font":
                    resGenerator.putFont(name, parseFont(resolved.innerText()));

                case "drawable":
                    resGenerator.putDrawable(name, parseDrawable(name, node, resGenerator));

                case "style":
                    styleParser.parse(name, node);

                case "selector":
                    selectorParser.parse(name, node);

                case "layout":
                    resGenerator.putLayout(name, parseLayout(name, node));

                default:
                    throw new UiParseError('unknown resource type: ${node.nodeName}');
            }
        }

        styleParser.toGenerator(resGenerator);
        selectorParser.toGenerator(resGenerator);
    }

    private function resolveResourceValue(node:Xml, visitedMap:Map<String, Bool> = null):Xml {
        var refInfo = ParseHelper.parseRef(node.innerText());

        if (refInfo == null) {
            return node;
        }

        var referenceKey = '${refInfo.type}/${refInfo.name}';

        if (visitedMap == null) {
            visitedMap = new Map<String, Bool>();
        } else if (visitedMap.exists(referenceKey)) {
            throw new UiParseError('circular dependency: @${referenceKey}');
        }

        if (!resourceMap.exists(referenceKey)) {
            throw new UiParseError('reference not found: @${referenceKey}');
        }

        visitedMap[node.nodeName + "/" + node.get("name")] = true;
        return resolveResourceValue(resourceMap.get(referenceKey), visitedMap);
    }

    private function parseString(s:String):String {
        return s.replace("\\n", "\n").trim().replace("\\t", "    ");
    }

    private function parseFont(value:String):GenFont {
        var value = value.trim();

        if (~/\.fnt$/i.match(value)) {
            return {
                ttfAssetId: null,
                bitmapName: value,
                bitmapImgAssetId: "font/" + ~/\.fnt$/i.replace(value, ".png"),
                bitmapXmlAssetId: "font/" + value,
            };
        } else {
            return {
                ttfAssetId: "font/" + value,
                bitmapName: null,
                bitmapImgAssetId: null,
                bitmapXmlAssetId: null,
            };
        }
    }

    private function parseDrawable(name:String, node:Xml, resGenerator:ResGenerator):Drawable {
        var drawableName = "@drawable/" + name;

        if (node.elements().count() != 1) {
            throw new UiParseError('${drawableName} must have exactly one child');
        }

        var innerNode = node.firstElement();

        if (innerNode.nodeName != "packed") {
            throw new UiParseError('${drawableName} must be packed');
        }

        var packedDrawable = innerNode.get("drawable");
        var packedX = Std.parseInt(innerNode.get("x"));
        var packedY = Std.parseInt(innerNode.get("y"));
        var packedW = Std.parseInt(innerNode.get("w"));
        var packedH = Std.parseInt(innerNode.get("h"));

        if (packedDrawable == null
            || packedDrawable == ""
            || packedX == null
            || packedY == null
            || packedW == null
            || packedH == null
        ) {
            throw new UiParseError('${drawableName} - error in packed node');
        }

        var refInfo = ParseHelper.parseRef(packedDrawable);

        if (refInfo == null || refInfo.type != "drawable") {
            throw new UiParseError('${drawableName} - invalid drawable reference');
        }

        var packedDrawable = resGenerator.getDrawable(refInfo.name);

        if (packedDrawable == null) {
            throw new UiParseError('${drawableName} - packed drawable not found');
        }

        if (packedDrawable.type != DrawableType.BITMAP) {
            throw new UiParseError('${drawableName} - packed drawable must have bitmap type');
        }

        return new Drawable(
            DrawableType.PACKED,
            packedDrawable.assetId,
            packedX,
            packedY,
            packedW,
            packedH
        );
    }

    private function parseLayout(name:String, node:Xml):Xml {
        if (node.elements().count() != 1) {
            throw new UiParseError('@layout/${name} must have exactly one child');
        }

        return node.firstElement();
    }
}
