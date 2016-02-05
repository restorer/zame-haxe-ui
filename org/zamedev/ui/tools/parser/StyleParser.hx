package org.zamedev.ui.tools.parser;

import org.zamedev.ui.errors.UiParseError;
import org.zamedev.ui.tools.generator.GenPosition;
import org.zamedev.ui.tools.generator.GenStyle;
import org.zamedev.ui.tools.generator.GenStyleRuntimeItem;

using org.zamedev.lib.XmlExt;

class StyleParser {
    public static function parse(name : String, node : Xml, pos : GenPosition) : GenStyle {
        var genStyle : GenStyle = {
            includeList : new Array<String>(),
            staticMap : new Map<String, String>(),
            runtimeMap : new Map<String, Array<GenStyleRuntimeItem>>(),
        };

        for (innerNode in node.elements()) {
            var innerName = innerNode.get("name");

            if (innerName == null || innerName == "") {
                throw new UiParseError('Item without name in "@style/${name}"', pos);
            }

            switch (innerNode.nodeName) {
                case "include":
                    genStyle.includeList.push(innerName);

                case "item":
                    parseStyleItem(genStyle, name, innerName, innerNode, pos);

                default:
                    throw new UiParseError('Invalid inner node "${innerNode.nodeName}" in "@style/${name}"', pos);
            }
        }

        return genStyle;
    }

    public static function postProcess(resGenerator : ResGenerator) : Void {
        for (styleName in resGenerator.styleMap.keys()) {
            for (genItemValue in resGenerator.styleMap[styleName].map) {
                genItemValue.value = resolveStyle(resGenerator, styleName, genItemValue.value, new Map<String, Bool>(), genItemValue.pos);
            }
        }
    }

    private static function parseStyleItem(genStyle : GenStyle, name : String, itemName : String, node : Xml, pos : GenPosition) : Void {
        if (node.firstElement() == null) {
            var innerChild = node.firstChild();

            if (innerChild.nodeType == Xml.PCData || innerChild.nodeType == Xml.Xml.CData) {
                genStyle.staticMap[itemName] = innerChild.nodeValue;
                return;
            }

            throw new UiParseError('Internal error occured while parsing style', pos);
        }

        genStyle.runtimeMap[itemName] = new Array<GenStyleRuntimeItem>();

        for (stateNode in node.elements()) {
            if (stateNode.nodeName != "state") {
                throw new UiParseError('Invalid inner node "${stateNode.nodeName}" for item "${itemName}" in "@style/${name}"', pos);
            }

            var styleRuntimeItem : GenStyleRuntimeItem = {
                stateMap : new Map<String, Bool>(),
                value : stateNode.innerText(),
            };

            for (att in stateNode.attributes()) {
                styleRuntimeItem.stateMap[att] = ParseHelper.parseBool(stateNode.get(att));
            }

            genStyle.runtimeMap[itemName].push(styleRuntimeItem);
        }
    }

    private static function resolveStyle(
        resGenerator : ResGenerator,
        styleName : String,
        genStyle : GenStyle,
        visitedMap:Map<String, Bool>,
        pos : GenPosition
    ) : GenStyle {
        var resGenStyle = {
            includeList : new Array<String>(),
            staticMap : new Map<String, String>(),
            runtimeMap : new Map<String, Array<GenStyleRuntimeItem>>(),
        };

        visitedMap[styleName] = true;

        for (includeName in genStyle.includeList) {
            var refInfo = ParseHelper.parseRef(includeName);

            if (refInfo == null || refInfo.type != "style") {
                throw new UiParseError('Invalid style reference "${includeName}" in "@style/${styleName}"', pos);
            }

            if (visitedMap.exists(refInfo.name)) {
                continue;
            }

            var incGenItem = resGenerator.styleMap[refInfo.name];

            if (incGenItem == null) {
                throw new UiParseError('Included style "${includeName}" not found in "@style/${styleName}"', pos);
            }

            var incGenStyle = resolveStyle(resGenerator, refInfo.name, resGenerator.findQualifiedValue(incGenItem.map, pos), visitedMap, pos);

            for (name in incGenStyle.staticMap.keys()) {
                resGenStyle.staticMap[name] = incGenStyle.staticMap[name];
            }

            for (name in incGenStyle.runtimeMap.keys()) {
                resGenStyle.runtimeMap[name] = incGenStyle.runtimeMap[name];
            }
        }

        for (name in genStyle.staticMap.keys()) {
            resGenStyle.staticMap[name] = genStyle.staticMap[name];
        }

        for (name in genStyle.runtimeMap.keys()) {
            resGenStyle.runtimeMap[name] = genStyle.runtimeMap[name];
        }

        return resGenStyle;
    }
}
