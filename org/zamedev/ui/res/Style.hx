package org.zamedev.ui.res;

import openfl.errors.Error;
import org.zamedev.ui.view.View;

class Style {
    var map:Map<String, TypedValue>;

    public function new(map:Map<String, TypedValue>) {
        this.map = map;
    }

    public function apply(view:View) {
        for (key in map.keys()) {
            if (!view.inflate(key, map[key])) {
                throw new Error("Apply error: unsupported attribute " + key);
            }
        }
    }
}
