package org.zamedev.ui.internal;

import openfl.display.Shape;

#if (js && dom)

import openfl._internal.renderer.RenderSession;
import openfl.display.DisplayObject;

class ShapeExt extends Shape {
    public var buttonMode(default, set):Bool = false;
    public var interactiveMode(default, set):Bool = true;

    @:noCompletion
    public override function __renderDOM(renderSession:RenderSession):Void {
        if (__canvas == null) {
            super.__renderDOM(renderSession);

            if (__canvas != null) {
                __canvas.style.cursor = (buttonMode ? "pointer" : "inherit");
                __canvas.style.setProperty("pointer-events", interactiveMode ? "auto" : "none", null);
            }
        } else {
            super.__renderDOM(renderSession);
        }
    }

    @:noCompletion
    private function set_buttonMode(value:Bool):Bool {
        buttonMode = value;

        if (__canvas != null) {
            __canvas.style.cursor = (buttonMode ? "pointer" : "inherit");
        }

        return value;
    }

    @:noCompletion
    private function set_interactiveMode(value:Bool):Bool {
        interactiveMode = value;

        if (__canvas != null) {
            __canvas.style.setProperty("pointer-events", interactiveMode ? "auto" : "none", null);
        }

        return value;
    }

    @:noCompletion
    override private function __hitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool):Bool {
        if (interactiveMode) {
            return super.__hitTest(x, y, shapeFlag, stack, interactiveOnly);
        } else {
            return false;
        }
    }
}

#else

typedef ShapeExt = Shape;

#end
