package org.zamedev.ui.widget;

import openfl.events.MouseEvent;
import org.zamedev.ui.Context;
import org.zamedev.ui.res.TypedValue;

class Radio extends Button {
    public var selected(get, set):Bool;
    public var groupTag:String;

    @:keep
    public function new(context:Context) {
        super(context);

        groupTag = null;

        addEventListener(MouseEvent.CLICK, onMouseClick);
    }

    override public function inflate(name:String, value:TypedValue):Bool {
        if (super.inflate(name, value)) {
            return true;
        }

        switch (name) {
            case "selected":
                selected = value.resolveBool();
                return true;

            case "groupTag":
                groupTag = value.resolveString();
                return true;
        }

        return false;
    }

    @:noCompletion
    private function onMouseClick(_):Void {
        selected = true;
    }

    @:noCompletion
    private function get_selected():Bool {
        return hasState("selected");
    }

    private function set_selected(value:Bool):Bool {
        updateState("selected", value);

        if (!isInLayout && _parent != null && groupTag != null) {
            for (child in _parent.findViewsByTag(groupTag, false)) {
                if (child != this) {
                    child.updateState("selected", false);
                }
            }
        }

        return value;
    }
}
