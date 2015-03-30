package org.zamedev.ui.res;

import org.zamedev.ui.view.View;

using StringTools;

class Selector {
    private var paramMap:Map<Int, Array<SelectorItem>>;

    public function new(paramMap:Map<Int, Array<SelectorItem>> = null) {
        if (paramMap != null) {
            this.paramMap = paramMap;
        } else {
            this.paramMap = new Map<Int, Array<SelectorItem>>();
        }
    }

    public function toString():String {
        var sb = new StringBuf();
        sb.add("[Selector {");

        for (key in paramMap.keys()) {
            sb.add(key);
            sb.add(" => [");

            sb.add(paramMap[key].map(function(v:SelectorItem):String {
                return "{stateMap => " + v.stateMap.toString() + ", value => " + Std.string(v.value) + "}";
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
                    view.inflate(cast key, item.value);
                    break;
                }
            }
        }
    }
}
