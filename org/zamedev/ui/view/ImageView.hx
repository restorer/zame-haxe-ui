package org.zamedev.ui.view;

import openfl.display.DisplayObject;
import org.zamedev.ui.Context;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.TypedValue;

class ImageView extends View {
    private var _drawable:Drawable;
    private var displayObject:DisplayObject;
    private var displayObjectCache:Map<String, DisplayObject>;
    private var imageWidth:Float;
    private var imageHeight:Float;

    public var drawable(get, set):Drawable;

    @:keep
    public function new(context:Context) {
        super(context);

        _drawable = null;
        displayObject = null;
        displayObjectCache = new Map<String, DisplayObject>();
        imageWidth = 0.0;
        imageHeight = 0.0;
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

    override private function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
        if (super.measureAndLayout(widthSpec, heightSpec)) {
            return true;
        }

        switch (widthSpec) {
            case MeasureSpec.UNSPECIFIED:
                _width = imageWidth;

            case MeasureSpec.EXACT(size):
                _width = size;

            case MeasureSpec.AT_MOST(size):
                _width = Math.min(size, imageWidth);
        }

        switch (heightSpec) {
            case MeasureSpec.UNSPECIFIED:
                _height = imageHeight;

            case MeasureSpec.EXACT(size):
                _height = size;

            case MeasureSpec.AT_MOST(size):
                _height = Math.min(size, imageHeight);
        }

        if (displayObject != null) {
            displayObject.width = _width;
            displayObject.height = _height;
        }

        return true;
    }

    @:noCompletion
    private function get_drawable():Drawable {
        return _drawable;
    }

    @:noCompletion
    private function set_drawable(value:Drawable):Drawable {
        if (Drawable.eq(_drawable, value)) {
            return value;
        }

        if (displayObject != null && displayObject.parent == _sprite) {
            _sprite.removeChild(displayObject);
        }

        _drawable = value;

        if (value != null) {
            displayObject = displayObjectCache[value.computeKey()];

            if (displayObject == null) {
                displayObject = value.resolve();
                displayObjectCache[value.computeKey()] = displayObject;
            }

            _sprite.addChild(displayObject);
            imageWidth = displayObject.width;
            imageHeight = displayObject.height;
        } else {
            imageWidth = 0.0;
            imageHeight = 0.0;
        }

        requestLayout();
        return value;
    }
}
