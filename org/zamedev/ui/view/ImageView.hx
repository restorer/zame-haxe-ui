package org.zamedev.ui.view;

import org.zamedev.ui.res.TypedValue;
import org.zamedev.ui.graphics.Drawable;
import openfl.display.DisplayObject;

class ImageView extends View {
    private var _drawable:Drawable;
    private var displayObject:DisplayObject;
    private var displayObjectCache:Map<String, DisplayObject>;

    public var drawable(get, set):Drawable;

    public function new() {
        super();

        _drawable = null;
        displayObject = null;
        displayObjectCache = new Map<String, DisplayObject>();
    }

    override public function inflate(name:String, value:TypedValue):Bool {
        if (super.inflate(name, value)) {
            return true;
        }

        switch (name) {
            case "drawable":
                drawable = value.resolveDrawable();
                return true;
        }

        return false;
    }

    @:noCompletion
    private function get_drawable():Drawable {
        return _drawable;
    }

    @:noCompletion
    private function set_drawable(value:Drawable):Drawable {
        if (_drawable == value) {
            return value;
        }

        if (displayObject != null && displayObject.parent == this) {
            removeChild(displayObject);
        }

        _drawable = value;

        if (value != null) {
            displayObject = displayObjectCache[value.computeKey()];

            if (displayObject == null) {
                displayObject = value.resolve();
                displayObjectCache[value.computeKey()] = displayObject;
            }

            addChild(displayObject);
        }

        measure();
        return value;
    }
}
