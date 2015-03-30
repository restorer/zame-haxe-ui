package org.zamedev.ui.res;

import org.zamedev.ui.view.View;

class Style {
    var map:Map<Int, Dynamic>;

    public function new(map:Map<Int, Dynamic>) {
        this.map = map;
    }

    public function apply(view:View) {
        for (key in map.keys()) {
            view.inflate(cast key, map[key]);
        }
    }
}
