package org.zamedev.ui.internal;

import openfl.display.Bitmap;

#if (js && dom)

import openfl._internal.renderer.RenderSession;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.PixelSnapping;

class BitmapExt extends Bitmap {
    public var interactiveMode(default, set):Bool = false;

    public function new(bitmapData:BitmapData = null, pixelSnapping:PixelSnapping = null, smoothing:Bool = false) {
        super(bitmapData, pixelSnapping, smoothing);
        // mouseEnabled = false;
    }

    @:noCompletion
    public override function __renderDOM(renderSession:RenderSession):Void {
        if (__style == null) {
            super.__renderDOM(renderSession);

            if (__style != null) {
                __style.cursor = (interactiveMode ? "pointer" : "inherit");
                __style.setProperty("pointer-events", interactiveMode ? "auto" : "none", null);
            }
        } else {
            super.__renderDOM(renderSession);
        }
    }

    @:noCompletion
    private function set_interactiveMode(value:Bool):Bool {
        interactiveMode = value;
        // mouseEnabled = value;

        if (__style != null) {
            __style.cursor = (interactiveMode ? "pointer" : "inherit");
            __style.setProperty("pointer-events", interactiveMode ? "auto" : "none", null);
        }

        return value;
    }

    @:noCompletion
    private override function __hitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool):Bool {
        if (!interactiveMode) {
            return false;
        }

        return super.__hitTest(x, y, shapeFlag, stack, interactiveOnly);
    }
}

#else

typedef BitmapExt = Bitmap;

#end
