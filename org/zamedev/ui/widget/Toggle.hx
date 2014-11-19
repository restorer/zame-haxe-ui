package org.zamedev.ui.widget;

import openfl.events.MouseEvent;
import org.zamedev.ui.res.TypedValue;
import motion.Actuate;

class Toggle extends Button {
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
        updateState("selected", !hasState("selected"));
    }

    @:noCompletion
    override private function set_textOffsetX(value:Float):Float {
        if (inflateFinished) {
            Actuate.tween(textView, 0.5, { offsetX: value });
        } else {
            textView.offsetX = value;
        }

        return value;
    }
}
