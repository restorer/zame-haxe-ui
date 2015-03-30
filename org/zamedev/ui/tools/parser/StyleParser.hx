package org.zamedev.ui.tools.parser;

import org.zamedev.ui.errors.UiParseError;
import org.zamedev.ui.tools.generator.GenStyle;

using org.zamedev.lib.XmlExt;

class StyleParser {
    private var styleSpecMap:Map<String, StyleSpec>;

    public function new():Void {
        styleSpecMap = new Map<String, StyleSpec>();
    }

    public function parse(name:String, node:Xml):Void {
        var styleSpec = {
            origName: name,
            name: "@style/" + name,
            includeList: new Array<String>(),
            itemMap: new Map<String, String>(),
        };

        for (innerNode in node.elements()) {
            var innerName = innerNode.get("name");

            if (innerName == null || innerName == "") {
                throw new UiParseError(styleSpec.name);
            }

            switch (innerNode.nodeName) {
                case "include":
                    styleSpec.includeList.push(innerName);

                case "item":
                    styleSpec.itemMap[innerName] = innerNode.innerText();

                default:
                    throw new UiParseError(styleSpec.name);
            }
        }

        styleSpecMap[styleSpec.name] = styleSpec;
    }

    public function toGenerator(resGenerator:ResGenerator):Void {
        for (name in styleSpecMap.keys()) {
            var styleSpec = styleSpecMap[name];
            resGenerator.putStyle(styleSpec.origName, resolveStyle(styleSpecMap, styleSpec));
        }
    }

    private static function resolveStyle(
        styleSpecMap:Map<String, StyleSpec>,
        styleSpec:StyleSpec,
        visitedMap:Map<String, Bool> = null
    ):GenStyle {
        var resolvedStyle = new Map<String, String>();

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
                throw new UiParseError('included style not found in ${styleSpec.name}');
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
}
