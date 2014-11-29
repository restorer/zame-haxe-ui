package org.zamedev.ui.internal;

import openfl.display.Shape;

#if (js && dom)

import openfl._internal.renderer.RenderSession;

class ShapeExt extends Shape {
    public var buttonMode(default, set):Bool = false;

    @:noCompletion
    public override function __renderDOM(renderSession:RenderSession):Void {
        if (__canvas == null) {
            super.__renderDOM(renderSession);

            if (__canvas != null) {
                __canvas.style.cursor = (buttonMode ? "pointer" : "inherit");
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
}

#else

typedef ShapeExt = Shape;

#end
