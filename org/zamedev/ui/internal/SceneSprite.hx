package org.zamedev.ui.internal;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

class SceneSprite extends Sprite {
    private var applicationStage : ApplicationStage;

    public var dispatchEvents : Bool;

    public function new(applicationStage : ApplicationStage) {
        super();

        this.applicationStage = applicationStage;
        this.dispatchEvents = false;

        addEventListener(Event.MOUSE_LEAVE, onEvent, true);
        addEventListener(MouseEvent.CLICK, onEvent, true);
        addEventListener(MouseEvent.DOUBLE_CLICK, onEvent, true);
        addEventListener(MouseEvent.MOUSE_DOWN, onEvent, true);
        addEventListener(MouseEvent.MOUSE_MOVE, onEvent, true);
        addEventListener(MouseEvent.MOUSE_OUT, onEvent, true);
        addEventListener(MouseEvent.MOUSE_OVER, onEvent, true);
        addEventListener(MouseEvent.MOUSE_UP, onEvent, true);
        addEventListener(MouseEvent.MOUSE_WHEEL, onEvent, true);
        addEventListener(MouseEvent.ROLL_OUT, onEvent, true);
        addEventListener(MouseEvent.ROLL_OVER, onEvent, true);

        #if !flash
            addEventListener(MouseEvent.MIDDLE_CLICK, onEvent, true);
            addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onEvent, true);
            addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onEvent, true);
            addEventListener(MouseEvent.RIGHT_CLICK, onEvent, true);
            addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onEvent, true);
            addEventListener(MouseEvent.RIGHT_MOUSE_UP, onEvent, true);
        #end
    }

    private function onEvent(e : Event) : Void {
        if (!dispatchEvents) {
            e.stopImmediatePropagation();
        }
    }

    #if flash
        @:noCompletion
        @:getter(width)
        private function get_width() : Float {
            return applicationStage.width;
        }

        @:noCompletion
        @:setter(width)
        private function set_width(value : Float) : Void {
        }

        @:noCompletion
        @:getter(height)
        private function get_height() : Float {
            return applicationStage.height;
        }

        @:noCompletion
        @:setter(height)
        private function set_height(value : Float) : Void {
        }
    #else
        @:noCompletion
        override private function get_width() : Float {
            return applicationStage.width;
        }

        @:noCompletion
        override private function set_width(value : Float) : Float {
            return value;
        }

        @:noCompletion
        override private function get_height() : Float {
            return applicationStage.height;
        }

        @:noCompletion
        override private function set_height(value : Float) : Float {
            return value;
        }
    #end
}
