package org.zamedev.ui.tools.parser;

import org.zamedev.ui.errors.UiParseError;
import org.zamedev.ui.tools.generator.GenPosition;
import org.zamedev.ui.tools.generator.GenStyle;
import org.zamedev.ui.tools.generator.GenStyleRuntimeItem;

using org.zamedev.lib.XmlExt;

class StyleParser {
    private var styleSpecMap : Map<String, StyleSpec>;

    public function new() {
        styleSpecMap = new Map<String, StyleSpec>();
    }

    public function parse(name : String, node : Xml, pos : GenPosition) : Void {
        var styleSpec = {
            origName : name,
            name : "@style/" + name,
            includeList : new Array<String>(),
            genStyle : {
                staticMap : new Map<String, String>(),
                runtimeMap : new Map<String, Array<GenStyleRuntimeItem>>(),
            },
            pos : pos,
        };

        for (innerNode in node.elements()) {
            var innerName = innerNode.get("name");

            if (innerName == null || innerName == "") {
                throw new UiParseError('Item without name for style "${styleSpec.name}"', pos);
            }

            switch (innerNode.nodeName) {
                case "include":
                    styleSpec.includeList.push(innerName);

                case "item":
                    parseStyleItem(styleSpec, innerName, innerNode, pos);

                default:
                    throw new UiParseError('Invalid inner node "${innerNode.nodeName}" for style "${styleSpec.name}"', pos);
            }
        }

        styleSpecMap[styleSpec.name] = styleSpec;
    }

    public function toGenerator(resGenerator : ResGenerator) : Void {
        for (name in styleSpecMap.keys()) {
            var styleSpec = styleSpecMap[name];
            resGenerator.putStyle(styleSpec.origName, resolveStyle(styleSpec, null, styleSpec.pos), styleSpec.pos);
        }
    }

    private function parseStyleItem(styleSpec : StyleSpec, itemName : String, node : Xml, pos : GenPosition) : Void {
        var genStyle = styleSpec.genStyle;

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
                throw new UiParseError('Invalid inner node "${stateNode.nodeName}" for item "${itemName}" for style "${styleSpec.name}"', pos);
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

    private function resolveStyle(styleSpec : StyleSpec, visitedMap:Map<String, Bool>, pos : GenPosition) : GenStyle {
        var resolvedStyle = {
            staticMap : new Map<String, String>(),
            runtimeMap : new Map<String, Array<GenStyleRuntimeItem>>(),
        };

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
                throw new UiParseError('Included style "${includeName}" not found in "${styleSpec.name}"', pos);
            }

            var includedStyle = resolveStyle(includeSpec, visitedMap, pos);

            for (name in includedStyle.staticMap.keys()) {
                resolvedStyle.staticMap[name] = includedStyle.staticMap[name];
            }

            for (name in includedStyle.runtimeMap.keys()) {
                resolvedStyle.runtimeMap[name] = includedStyle.runtimeMap[name];
            }
        }

        for (name in styleSpec.genStyle.staticMap.keys()) {
            resolvedStyle.staticMap[name] = styleSpec.genStyle.staticMap[name];
        }

        for (name in styleSpec.genStyle.runtimeMap.keys()) {
            resolvedStyle.runtimeMap[name] = styleSpec.genStyle.runtimeMap[name];
        }

        return resolvedStyle;
    }
}
