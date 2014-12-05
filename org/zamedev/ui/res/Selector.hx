package org.zamedev.ui.res;

import openfl.errors.Error;
import org.zamedev.ui.view.View;

using StringTools;

typedef SelectorItem = {
    stateMap:Map<String, Bool>,
    value:TypedValue,
};

class Selector {
    private var paramMap:Map<String, Array<SelectorItem>>;

    public function new(paramMap:Map<String, Array<SelectorItem>> = null) {
        if (paramMap != null) {
            this.paramMap = paramMap;
        } else {
            this.paramMap = new Map<String, Array<SelectorItem>>();
        }
    }

    public function toString():String {
        var sb = new StringBuf();
        sb.add("[Selector {");

        for (key in paramMap.keys()) {
            sb.add(key);
            sb.add(" => [");

            sb.add(paramMap[key].map(function(v:SelectorItem):String {
                return "{stateMap => " + v.stateMap.toString() + ", value => " + v.value.toString() + "}";
            }).join(", "));

            sb.add("]");
        }

        sb.add("}]");
        return sb.toString();
    }

    public function apply(view:View, stateMap:Map<String, Bool>):Void {
        for (key in paramMap.keys()) {
            for (item in paramMap[key]) {
                var matched = true;

                for (key in item.stateMap.keys()) {
                    if (item.stateMap[key] && item.stateMap[key] != stateMap[key]) {
                        matched = false;
                        break;
                    }
                }

                if (matched) {
                    view.inflate(key, item.value);
                    break;
                }
            }
        }
    }
}
