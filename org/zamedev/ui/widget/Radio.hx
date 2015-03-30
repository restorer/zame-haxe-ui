package org.zamedev.ui.widget;

import openfl.events.MouseEvent;
import org.zamedev.ui.Context;
import org.zamedev.ui.res.Styleable;

class Radio extends Button {
    public var selected(get, set):Bool;
    public var groupTag:String;

    @:keep
    public function new(context:Context) {
        super(context);

        groupTag = null;

        addEventListener(MouseEvent.CLICK, onMouseClick);
    }

    override private function _inflate(attId:Styleable, value:Dynamic):Bool {
        if (super._inflate(attId, value)) {
            return true;
        }

        switch (attId) {
            case Styleable.selected:
                selected = cast value;
                return true;

            case Styleable.groupTag:
                groupTag = cast value;
                return true;

            default:
                return false;
        }
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

        if (!isInLayout && parent != null && groupTag != null) {
            for (child in parent.findViewsByTag(groupTag, false)) {
                if (child != this) {
                    child.updateState("selected", false);
                }
            }
        }

        return value;
    }
}
