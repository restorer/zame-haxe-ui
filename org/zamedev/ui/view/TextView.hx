package org.zamedev.ui.view;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.text.TextFormat;
import org.zamedev.ui.Context;
import org.zamedev.ui.internal.TextFieldExt;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.TypedValue;

class TextView extends View {
    private var _textFormat:TextFormat;
    private var textField:TextFieldExt;

    #if (!flash && !webgl && !dom)
        private var cachedBitmap:Bitmap;
    #end

    public var textColor(get, set):Null<UInt>;
    public var textSize(get, set):Null<Float>;
    public var font(get, set):String;
    public var text(get, set):String;

    public function new(context:Context) {
        super(context);

        _textFormat = new TextFormat();
        textField = new TextFieldExt();

        textField.selectable = false;
        textField.defaultTextFormat = _textFormat;

        #if (!flash && !webgl && !dom)
            cachedBitmap = new Bitmap();
            _sprite.addChild(cachedBitmap);
        #else
            _sprite.addChild(textField);
        #end

        // textField.backgroundColor = 0x800000;
        // textField.background = true;
    }

    override public function inflate(name:String, value:TypedValue):Bool {
        if (super.inflate(name, value)) {
            return true;
        }

        switch (name) {
            case "textColor":
                textColor = value.resolveColor();
                return true;

            case "textSize":
                textSize = computeDimension(value.resolveDimension(), true);
                return true;

            case "font":
                font = value.resolveFont();
                return true;

            case "text":
                text = value.resolveString();
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
                textField.width = 512;

            case MeasureSpec.EXACT(size) | MeasureSpec.AT_MOST(size):
                textField.width = size;
        }

        switch (heightSpec) {
            case MeasureSpec.UNSPECIFIED:
                textField.height = 512;

            case MeasureSpec.EXACT(size) | MeasureSpec.AT_MOST(size):
                textField.height = size;
        }

        switch (widthSpec) {
            case MeasureSpec.UNSPECIFIED | MeasureSpec.AT_MOST(_):
                #if android
                    _width = textField.textWidth * 1.1;
                #else
                    _width = textField.textWidth;
                #end

                switch (widthSpec) {
                    case MeasureSpec.AT_MOST(size):
                        _width = Math.min(size, _width);

                    default:
                }

            case MeasureSpec.EXACT(size):
                _width = size;
        }

        textField.width = _width;

        switch (heightSpec) {
            case MeasureSpec.UNSPECIFIED | MeasureSpec.AT_MOST(_):
                _height = textField.textHeight;

                switch (heightSpec) {
                    case MeasureSpec.AT_MOST(size):
                        _height = Math.min(size, _height);

                    default:
                }

            case MeasureSpec.EXACT(size):
                _height = size;
        }

        textField.height = _height;

        #if (!flash && !webgl && !dom)
            updateCache();
        #end

        return true;
    }

    #if (!flash && !webgl && !dom)
        private function updateCache():Void {
            var cachedBitmapData = new BitmapData(
                Std.int(Math.max(1, Math.ceil(_width))),
                Std.int(Math.max(1, Math.ceil(_height))),
                true,
                0
            );

            cachedBitmapData.draw(textField);
            cachedBitmap.bitmapData = cachedBitmapData;
            cachedBitmap.smoothing = true;
        }
    #end

    @:noCompletion
    private function get_textColor():Null<UInt> {
        return _textFormat.color;
    }

    @:noCompletion
    private function set_textColor(value:Null<UInt>):Null<UInt> {
        if (_textFormat.color != value) {
            _textFormat.color = value;
            textField.defaultTextFormat = _textFormat;
            textField.setTextFormat(_textFormat);

            #if (!flash && !webgl && !dom)
                updateCache();
            #end
        }

        return value;
    }

    @:noCompletion
    private function get_textSize():Null<Float> {
        return _textFormat.size;
    }

    @:noCompletion
    private function set_textSize(value:Null<Float>):Null<Float> {
        if (_textFormat.size != value) {
            _textFormat.size = value;
            textField.defaultTextFormat = _textFormat;
            textField.setTextFormat(_textFormat);
            requestLayout();
        }

        return value;
    }

    @:noCompletion
    private function get_font():String {
        return _textFormat.font;
    }

    @:noCompletion
    private function set_font(value:String):String {
        if (_textFormat.font != value) {
            _textFormat.font = value;
            textField.embedFonts = true;
            textField.defaultTextFormat = _textFormat;
            textField.setTextFormat(_textFormat);
            requestLayout();
        }

        return value;
    }

    @:noCompletion
    private function get_text():String {
        return textField.text;
    }

    @:noCompletion
    private function set_text(value:String):String {
        if (textField.text != value) {
            textField.text = value;
            requestLayout();
        }

        return value;
    }
}
