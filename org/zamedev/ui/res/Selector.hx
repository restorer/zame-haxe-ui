package org.zamedev.ui.res;

import openfl.errors.Error;

using StringTools;

typedef SelectorItem = {
    stateMap:Map<String, Bool>,
    paramMap:Map<String, TypedValue>,
};

class Selector {
    private var list:Array<Array<SelectorItem>>;

    public function new(list:Array<Array<SelectorItem>> = null) {
        if (list != null) {
            this.list = list;
        } else {
            this.list = new Array<Array<SelectorItem>>();
        }
    }

    public function toString():String {
        return "[Selector [" + list.map(function(v:Array<SelectorItem>):String {
            return v.map(function(vv:SelectorItem):String {
                return "{stateMap => " + vv.stateMap.toString() + ", paramMap => " + vv.paramMap.toString() + "}";
            }).join(", ");
        }).join("], [") + "]]";
    }

    public function match(stateMap:Map<String, Bool>):Map<String, TypedValue> {
        var result = new Map<String, TypedValue>();

        for (itemList in list) {
            for (item in itemList) {
                var matched = true;

                for (key in item.stateMap.keys()) {
                    if (item.stateMap[key] && item.stateMap[key] != stateMap[key]) {
                        matched = false;
                        break;
                    }
                }

                if (matched) {
                    for (key in item.paramMap.keys()) {
                        result[key] = item.paramMap[key];
                    }

                    break;
                }
            }
        }

        return result;
    }

    public static function parse(resourceManager:ResourceManager, resId:String):Selector {
        var list = new Array<Array<SelectorItem>>();
        _parse(resourceManager, resId, list, new Map<String, Bool>());
        return new Selector(list);
    }

    private static function _parse(
        resourceManager:ResourceManager,
        resId:String,
        list:Array<Array<SelectorItem>>,
        visitedMap:Map<String, Bool>
    ):Void {
        var xmlString = resourceManager._getSelectorText(resId);
        var root = Xml.parse(xmlString).elementsNamed("selector").next();

        if (root == null) {
            throw new Error("Parse error: " + resId);
        }

        var itemList = new Array<SelectorItem>();

        for (node in root.elements()) {
            if (node.nodeName == "include") {
                var includeId = node.get("name");

                if (includeId == null || includeId == "") {
                    throw new Error("Parse error: " + resId);
                }

                visitedMap[resId] = true;

                if (!visitedMap.exists(includeId)) {
                    _parse(resourceManager, includeId, list, visitedMap);
                }

                continue;
            }

            if (node.nodeName != "item") {
                throw new Error("Parse error: " + resId);
            }

            var selectorItem = {
                stateMap: new Map<String, Bool>(),
                paramMap: new Map<String, TypedValue>(),
            };

            for (att in node.attributes()) {
                if (att.substr(0, 6) == "state_") {
                    selectorItem.stateMap[att.substr(6)] = (node.get(att).trim().toLowerCase() == "true");
                } else {
                    throw new Error("Parse error: " + resId);
                }
            }

            for (innerNode in node.elements()) {
                if (innerNode.nodeName != "param") {
                    throw new Error("Parse error: " + resId);
                }

                var paramName = innerNode.get("name");

                if (paramName == null || paramName == "") {
                    throw new Error("Parse error: " + resId);
                }

                var paramValue = innerNode.get("value");

                if (paramValue == null) {
                    throw new Error("Parse error: " + resId);
                }

                selectorItem.paramMap[paramName] = new TypedValue(resourceManager, paramValue);
            }

            itemList.push(selectorItem);
        }

        if (itemList.length != 0) {
            list.push(itemList);
        }
    }
}
