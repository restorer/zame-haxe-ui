package org.zamedev.lib.engine;

import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

class Button extends Sprite {
    private static var CUSTOM_CLICK:String = "customClick";

    public var upState(default, set):DisplayObject;
    public var downState(default, set):DisplayObject;
    public var pushedDown(default, set):Bool;
    public var enabled:Bool;

    @:noCompletion private var __currentState(default, set):DisplayObject;
    @:noCompletion private var __pressed:Bool;
    @:noCompletion private var __currentUpState:DisplayObject;

    public function new(upState:DisplayObject = null, downState:DisplayObject = null) {
        super();

        enabled = true;
        __pressed = false;

        this.upState = (upState != null ? upState : new Sprite());
        this.downState = (downState != null ? downState : new Sprite());

        __currentState = this.upState;
        pushedDown = false;

        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
    }

    override public function addEventListener(
        type:String,
        listener:Dynamic->Void,
        useCapture:Bool = false,
        priority:Int = 0,
        useWeakReference:Bool = false
    ):Void {
        if (type == MouseEvent.CLICK) {
            type = CUSTOM_CLICK;
        }

        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    override public function removeEventListener(type:String, listener:Dynamic->Void, capture:Bool = false):Void {
        if (type == MouseEvent.CLICK) {
            type = CUSTOM_CLICK;
        }

        super.removeEventListener(type, listener, capture);
    }

    @:noCompletion private function onMouseDown(e:Event):Void {
        if (!__pressed && enabled) {
            __pressed = true;
            __currentState = downState;

            if (stage != null) {
                stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
                stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
            }
        }
    }

    @:noCompletion private function onMouseUp(e:Event):Void {
        if (__pressed) {
            dispatchEvent(new Event(CUSTOM_CLICK));
        }
    }

    @:noCompletion private function onMouseMove(e:Event):Void {
        if (__pressed) {
            e.stopPropagation();

            if (__currentState != downState) {
                __currentState = downState;
            }
        }
    }

    @:noCompletion private function onRemovedFromStage(_):Void {
        if (__pressed) {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
        }
    }

    @:noCompletion private function onStageMouseMove(_):Void {
        if (__currentState != __currentUpState) {
            __currentState = __currentUpState;
        }
    }

    @:noCompletion private function onStageMouseUp(_):Void {
        if (__pressed) {
            __pressed = false;
            __currentState = __currentUpState;

            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
        }
    }

    @:noCompletion private function switchState(state:DisplayObject):Void {
        if (__currentState != null && __currentState.stage != null) {
            removeChild(__currentState);
            addChild(state);
        } else {
            addChild(state);
        }
    }

    @:noCompletion private function set_pushedDown(pushedDown:Bool):Bool {
        if (this.pushedDown != pushedDown) {
            __currentUpState = (pushedDown ? downState : upState);
            __currentState = __currentUpState;
        }

        return this.pushedDown = pushedDown;
    }

    @:noCompletion private function set_upState(upState:DisplayObject):DisplayObject {
        if (this.upState != null && __currentState == this.upState) {
            __currentState = upState;
        }

        if (__currentUpState == this.upState) {
            __currentUpState = upState;
        }

        return this.upState = upState;
    }

    @:noCompletion private function set_downState(downState:DisplayObject):DisplayObject {
        if (this.downState != null && __currentState == this.downState) {
            __currentState = downState;
        }

        if (__currentUpState == this.downState) {
            __currentUpState = downState;
        }

        return this.downState = downState;
    }

    @:noCompletion private function set___currentState(state:DisplayObject):DisplayObject {
        if (__currentState == state) {
            return state;
        }

        switchState(state);
        return __currentState = state;
    }
}
