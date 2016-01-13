package org.zamedev.ui.view;

import openfl.display.DisplayObject;
import openfl.events.MouseEvent;
import org.zamedev.ui.Context;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.Styleable;

class ImageView extends View {
    private var _drawable : Drawable;
    private var displayObject : DisplayObject;
    private var displayObjectCache : Map<String, DisplayObject>;
    private var imageWidth : Float;
    private var imageHeight : Float;
    private var _scaleX : Float;
    private var _scaleY : Float;

    public var drawable(get, set) : Drawable;
    public var scaleX(get, set) : Float;
    public var scaleY(get, set) : Float;
    public var scale(never, set) : Float;

    @:keep
    public function new(context : Context) {
        super(context);

        _drawable = null;
        displayObject = null;
        displayObjectCache = new Map<String, DisplayObject>();
        imageWidth = 0.0;
        imageHeight = 0.0;
        _scaleX = 1.0;
        _scaleY = 1.0;
    }

    override private function _inflate(attId : Styleable, value : Dynamic) : Bool {
        if (super._inflate(attId, value)) {
            return true;
        }

        switch (attId) {
            case Styleable.drawable:
                drawable = cast value;
                return true;

            case Styleable.scaleX:
                scaleX = cast value;
                return true;

            case Styleable.scaleY:
                scaleY = cast value;
                return true;

            case Styleable.scale:
                scale = cast value;
                return true;

            default:
                return false;
        }
    }

    override private function measureAndLayout(widthSpec : MeasureSpec, heightSpec : MeasureSpec) : Bool {
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

    override public function addEventListener(
        type:String,
        listener:Dynamic -> Void,
        useCapture:Bool = false,
        priority:Int = 0,
        useWeakReference:Bool = false
    ):Void {
        if (type == MouseEvent.CLICK) {
            sprite.addEventListener(type, listener, useCapture, priority, useWeakReference);
        } else {
            super.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
    }

    override public function removeEventListener(type : String, listener : Dynamic -> Void, capture : Bool = false) : Void {
        if (type == MouseEvent.CLICK) {
            sprite.removeEventListener(type, listener, capture);
        } else {
            super.removeEventListener(type, listener, capture);
        }
    }

    @:noCompletion
    private function get_drawable() : Drawable {
        return _drawable;
    }

    @:noCompletion
    private function set_drawable(value : Drawable) : Drawable {
        if (Drawable.equals(_drawable, value)) {
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

            displayObject.scaleX = _scaleX;
            displayObject.scaleY = _scaleY;

            imageWidth = displayObject.width;
            imageHeight = displayObject.height;
        } else {
            imageWidth = 0.0;
            imageHeight = 0.0;
        }

        requestLayout();
        return value;
    }

    @:keep
    @:noCompletion
    private function get_scaleX() : Float {
        return _scaleX;
    }

    @:keep
    @:noCompletion
    private function set_scaleX(value : Float) : Float {
        if (_scaleX != value) {
            _scaleX = value;

            if (displayObject != null) {
                displayObject.scaleX = value;
                imageWidth = displayObject.width;
                requestLayout();
            }
        }

        return value;
    }

    @:keep
    @:noCompletion
    private function get_scaleY() : Float {
        return _scaleY;
    }

    @:keep
    @:noCompletion
    private function set_scaleY(value : Float) : Float {
        if (_scaleY != value) {
            _scaleY = value;

            if (displayObject != null) {
                displayObject.scaleY = value;
                imageHeight = displayObject.height;
                requestLayout();
            }
        }

        return value;
    }

    @:noCompletion
    private function set_scale(value : Float) : Float {
        if (value != _scaleX || value != _scaleY) {
            _scaleX = value;
            _scaleY = value;

            if (displayObject != null) {
                displayObject.scaleX = value;
                displayObject.scaleY = value;

                imageWidth = displayObject.width;
                imageHeight = displayObject.height;

                requestLayout();
            }
        }

        return value;
    }
}
