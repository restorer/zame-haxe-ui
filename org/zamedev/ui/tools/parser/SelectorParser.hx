package org.zamedev.ui.tools.parser;

import org.zamedev.ui.errors.UiParseError;
import org.zamedev.ui.tools.generator.GenSelector;
import org.zamedev.ui.tools.generator.GenSelectorItem;

using StringTools;
using org.zamedev.lib.XmlExt;

class SelectorParser {
    private var selectorSpecMap:Map<String, SelectorSpec>;

    public function new():Void {
        selectorSpecMap = new Map<String, SelectorSpec>();
    }

    public function parse(name:String, node:Xml):Void {
        var selectorSpec = {
            origName: name,
            name: "@selector/" + name,
            includeList: new Array<String>(),
            paramMap: new Map<String, Array<GenSelectorItem>>(),
        };

        for (innerNode in node.elements()) {
            var innerName = innerNode.get("name");

            if (innerName == null || innerName == "") {
                throw new UiParseError(selectorSpec.name);
            }

            switch (innerNode.nodeName) {
                case "include":
                    selectorSpec.includeList.push(innerName);

                case "param": {
                    selectorSpec.paramMap[innerName] = new Array<GenSelectorItem>();

                    for (stateNode in innerNode.elements()) {
                        if (stateNode.nodeName != "state") {
                            throw new UiParseError(selectorSpec.name);
                        }

                        var selectorItem = {
                            stateMap: new Map<String, Bool>(),
                            value: stateNode.innerText(),
                        };

                        for (att in stateNode.attributes()) {
                            selectorItem.stateMap[att] = (stateNode.get(att).trim().toLowerCase() == "true");
                        }

                        selectorSpec.paramMap[innerName].push(selectorItem);
                    }
                }

                default:
                    throw new UiParseError(selectorSpec.name);
            }
        }

        selectorSpecMap[selectorSpec.name] = selectorSpec;
    }

    public function toGenerator(resGenerator:ResGenerator):Void {
        for (name in selectorSpecMap.keys()) {
            var selectorSpec = selectorSpecMap[name];
            resGenerator.putSelector(selectorSpec.origName, resolveSelector(selectorSpecMap, selectorSpec));
        }
    }

    private static function resolveSelector(
        selectorSpecMap:Map<String, SelectorSpec>,
        selectorSpec:SelectorSpec,
        visitedMap:Map<String, Bool> = null
    ):GenSelector {
        var resolvedSelector = new Map<String, Array<GenSelectorItem>>();

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
                throw new UiParseError('included selector not found in ${selectorSpec.name}');
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
