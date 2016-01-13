package org.zamedev.ui.tools;

import org.zamedev.lib.ds.LinkedMap;
import org.zamedev.ui.errors.UiParseError;
import org.zamedev.ui.graphics.Color;
import org.zamedev.ui.graphics.DimensionTools;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.i18n.Quantity;
import org.zamedev.ui.tools.generator.GenFont;
import org.zamedev.ui.tools.generator.GenPlural;
import org.zamedev.ui.tools.generator.GenPosition;
import org.zamedev.ui.tools.parser.ConfigurationHelper;
import org.zamedev.ui.tools.parser.ParseHelper;
import org.zamedev.ui.tools.parser.ParseItem;
import org.zamedev.ui.tools.parser.StyleParser;

using StringTools;
using org.zamedev.lib.LambdaExt;
using org.zamedev.lib.XmlExt;

@:access(org.zamedev.ui.graphics.Drawable)
class ResParser {
    private var resourceMap : LinkedMap<String, Map<String, ParseItem>>;

    public function new() {
        resourceMap = new LinkedMap<String, Map<String, ParseItem>>();
    }

    public function parseResources(xmlString : String, pos : GenPosition) : Void {
        var root = Xml.parse(xmlString).elementsNamed("resources").next();

        if (root == null) {
            throw new UiParseError("Xml must have \"resources\" root node", pos);
        }

        for (node in root.elements()) {
            // TODO: somehow get line number in xml file
            var name = node.get("name");

            if (name == null) {
                throw new UiParseError("Node with empty name found", pos);
            }

            var resPath = node.nodeName + "/" + name;
            var qKey = pos.configuration.toQualifierString();

            if (!resourceMap.exists(resPath)) {
                resourceMap[resPath] = new Map<String, ParseItem>();
            } else if (resourceMap[resPath].exists(qKey)) {
                throw new UiParseError(
                    'Duplicate resource "${name}" of type "${node.nodeName}"' + (qKey == "" ? "" : ' (for "${qKey}")'),
                    pos
                );
            }

            resourceMap[resPath][qKey] = {
                node : node,
                pos : pos,
            }
        }
    }

    public function toGenerator(resGenerator : ResGenerator) : Void {
        var styleParser = new StyleParser();

        for (itemMap in resourceMap) {
            for (item in itemMap) {
                var resolved = resolveResourceValue(item.node, null, item.pos);
                var name = item.node.get("name");

                switch (item.node.nodeName) {
                    case "color":
                        resGenerator.putColor(name, Color.parse(resolved.innerText(), item.pos), item.pos);

                    case "dimen":
                        resGenerator.putDimension(name, DimensionTools.parse(resolved.innerText(), item.pos), item.pos);

                    case "string":
                        resGenerator.putString(name, parseString(resolved.innerText()), item.pos);

                    case "plurals":
                        resGenerator.putPlural(name, parsePlural(name, resolved, item.pos), item.pos);

                    case "font":
                        resGenerator.putFont(name, parseFont(resolved.innerText()), item.pos);

                    case "drawable":
                        resGenerator.putDrawable(name, parseDrawable(name, item.node, resGenerator, item.pos), item.pos);

                    case "style":
                        styleParser.parse(name, item.node, item.pos);

                    case "layout":
                        resGenerator.putLayout(name, parseLayout(resGenerator, name, item.node, item.pos), item.pos);

                    case "layoutpart":
                        resGenerator.putLayoutPart(name, parseLayout(resGenerator, name, item.node, item.pos), item.pos);

                    default:
                        throw new UiParseError('Unknown resource of type "${item.node.nodeName}"', item.pos);
                }
            }
        }

        styleParser.toGenerator(resGenerator);
    }

    private function resolveResourceValue(node : Xml, visitedMap : Map<String, Bool>, pos : GenPosition) : Xml {
        var refInfo = ParseHelper.parseRef(node.innerText());

        if (refInfo == null) {
            return node;
        }

        var referenceKey = '${refInfo.type}/${refInfo.name}';

        if (visitedMap == null) {
            visitedMap = new Map<String, Bool>();
        } else if (visitedMap.exists(referenceKey)) {
            throw new UiParseError('Circular dependency: @${referenceKey}', pos);
        }

        if (!resourceMap.exists(referenceKey)) {
            throw new UiParseError('Reference not found: @${referenceKey}', pos);
        }

        visitedMap[node.nodeName + "/" + node.get("name")] = true;
        var itemMap = resourceMap[referenceKey];

        for (key in ConfigurationHelper.computeQualifierKeys(pos.configuration)) {
            if (itemMap.exists(key)) {
                return resolveResourceValue(itemMap[key].node, visitedMap, pos);
            }
        }

        throw new UiParseError("Internal error", pos);
    }

    private function parseString(s : String) : String {
        return s.replace("\\n", "\n").trim().replace("\\t", "    ");
    }

    private function parsePlural(name : String, node : Xml, pos : GenPosition) : GenPlural {
        var result = new Map<Quantity, String>();

        for (innerNode in node.elements()) {
            if (innerNode.nodeName != "item") {
                throw new UiParseError('Invalid inner node "${innerNode.nodeName}" for plural "${name}"', pos);
            }

            var quantityStr = innerNode.get("quantity");

            if (quantityStr == null) {
                throw new UiParseError('Item without quantity found for plural "${name}"', pos);
            }

            result[ParseHelper.parseQuantity(quantityStr, pos)] = innerNode.innerText();
        }

        return result;
    }

    private function parseFont(value : String) : GenFont {
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

    private function parseDrawable(name : String, node : Xml, resGenerator : ResGenerator, pos : GenPosition) : Drawable {
        var drawableName = "@drawable/" + name;

        if (node.elements().count() != 1) {
            throw new UiParseError('${drawableName} must have exactly one child', pos);
        }

        var innerNode = node.firstElement();

        if (innerNode.nodeName != "packed") {
            throw new UiParseError('${drawableName} must be packed', pos);
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
            throw new UiParseError('${drawableName} - error in packed node', pos);
        }

        var refInfo = ParseHelper.parseRef(packedDrawable);

        if (refInfo == null || refInfo.type != "drawable") {
            throw new UiParseError('${drawableName} - invalid drawable reference', pos);
        }

        var packedDrawable = resGenerator.getPackedDrawable(refInfo.name, pos);
        return Drawable.fromAssetPacked(packedDrawable.id, packedX, packedY, packedW, packedH);
    }

    private function parseLayout(resGenerator : ResGenerator, name : String, node : Xml, pos : GenPosition) : Xml {
        if (node.elements().count() != 1) {
            throw new UiParseError('@layout/${name} must have exactly one child', pos);
        }

        var layoutRoot = node.firstElement();
        extractIds(resGenerator, layoutRoot, pos);
        return layoutRoot;
    }

    private function extractIds(resGenerator : ResGenerator, node : Xml, pos : GenPosition) : Void {
        for (att in node.attributes()) {
            var value = node.get(att);

            if (value.substr(0, 4) == "@id/") {
                resGenerator.putIdentifier(value.substr(4), pos);
            }
        }

        for (innerNode in node.elements()) {
            extractIds(resGenerator, innerNode, pos);
        }
    }
}
