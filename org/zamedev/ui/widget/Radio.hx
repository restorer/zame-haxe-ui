package org.zamedev.ui.widget;

import openfl.events.MouseEvent;
import org.zamedev.ui.res.TypedValue;

class Radio extends Button {
    public function new() {
        super();
        addEventListener(MouseEvent.CLICK, onMouseClick);
    }

    override public function inflate(name:String, value:TypedValue):Bool {
        if (super.inflate(name, value)) {
            return true;
        }

        switch (name) {
            case "selected":
                updateState("selected", value.resolveBool());
                return true;
        }

        return false;
    }

    @:noCompletion
    private function onMouseClick(_):Void {
        if (_parent != null && tag != null) {
            for (child in _parent.findChildrenByTag(tag, false)) {
                if (child != this) {
                    child.updateState("selected", false);
                }
            }
        }

        updateState("selected", true);
    }
}
