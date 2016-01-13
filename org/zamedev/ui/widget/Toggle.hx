package org.zamedev.ui.widget;

import motion.Actuate;
import openfl.events.MouseEvent;
import org.zamedev.ui.Context;
import org.zamedev.ui.res.Styleable;

class Toggle extends Button {
    @:keep
    public function new(context : Context) {
        super(context);
        addEventListener(MouseEvent.CLICK, onMouseClick);
    }

    override private function _inflate(attId : Styleable, value : Dynamic) : Bool {
        if (super._inflate(attId, value)) {
            return true;
        }

        switch (attId) {
            case Styleable.selected:
                updateState("selected", cast value);
                return true;

            default:
                return false;
        }
    }

    @:noCompletion
    private function onMouseClick(_) : Void {
        updateState("selected", !hasState("selected"));
    }

    @:noCompletion
    override private function set_textOffsetX(value : Float) : Float {
        if (isInLayout || !isAddedToApplicationStage) {
            textView.offsetX = value;
        } else {
            Actuate.tween(textView, 0.5, { offsetX: value });
        }

        return value;
    }
}
