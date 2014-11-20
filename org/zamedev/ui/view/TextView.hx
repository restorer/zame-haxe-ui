package org.zamedev.ui.view;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.text.TextFormat;
import org.zamedev.ui.internal.TextFieldExt;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.TypedValue;

class TextView extends View {
    private var _textFormat:TextFormat;
    private var textField:TextFieldExt;
    private var cachedBitmap:Bitmap;
    private var cachedBitmapData:BitmapData;

    public var textColor(get, set):Null<UInt>;
    public var textSize(get, set):Null<Float>;
    public var font(get, set):String;
    public var text(get, set):String;

    public function new() {
        super();

        _textFormat = new TextFormat();
        textField = new TextFieldExt();
        cachedBitmap = new Bitmap();
        cachedBitmapData = null;

        textField.selectable = false;
        textField.defaultTextFormat = _textFormat;

        _sprite.addChild(cachedBitmap);

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
                textSize = value.resolveFloat();
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

    override public function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
        if (super.measureAndLayout(widthSpec, heightSpec)) {
            return true;
        }

        switch (widthSpec) {
            case MeasureSpec.UNSPECIFIED:
                textField.width = 1000;

            case MeasureSpec.EXACT(size) | MeasureSpec.AT_MOST(size):
                textField.width = size;
        }

        switch (heightSpec) {
            case MeasureSpec.UNSPECIFIED:
                textField.height = 1000;

            case MeasureSpec.EXACT(size) | MeasureSpec.AT_MOST(size):
                textField.height = size;
        }

        switch (widthSpec) {
            case MeasureSpec.UNSPECIFIED | MeasureSpec.AT_MOST(_):
                #if js
                    _width = textField.textWidth;
                #elseif android
                    _width = textField.textWidth * 1.1;
                #else
                    _width = textField.textWidth + 4;
                #end

                switch (widthSpec) {
                    case MeasureSpec.AT_MOST(size):
                        _width = Math.min(size, _width);

                    default:
                }

                textField.width = _width;

            case MeasureSpec.EXACT(size):
                _width = size;
        }

        switch (heightSpec) {
            case MeasureSpec.UNSPECIFIED | MeasureSpec.AT_MOST(_):
                _height = textField.textHeight;

                switch (heightSpec) {
                    case MeasureSpec.AT_MOST(size):
                        _height = Math.min(size, _height);

                    default:
                }

                textField.height = _height;

            case MeasureSpec.EXACT(size):
                _height = size;
        }

        updateCache();
        return true;
    }

    private function updateCache():Void {
        cachedBitmapData = new BitmapData(Math.ceil(_width), Math.ceil(_height), true, 0);
        cachedBitmapData.draw(textField);
        cachedBitmap.bitmapData = cachedBitmapData;
    }

    @:noCompletion
    private function get_textColor():Null<UInt> {
        return _textFormat.color;
    }

    @:noCompletion
    private function set_textColor(value:Null<UInt>):Null<UInt> {
        _textFormat.color = value;
        textField.defaultTextFormat = _textFormat;
        textField.setTextFormat(_textFormat);
        updateCache();
        return value;
    }

    @:noCompletion
    private function get_textSize():Null<Float> {
        return _textFormat.size;
    }

    @:noCompletion
    private function set_textSize(value:Null<Float>):Null<Float> {
        _textFormat.size = value;
        textField.defaultTextFormat = _textFormat;
        textField.setTextFormat(_textFormat);
        requestLayout();
        return value;
    }

    @:noCompletion
    private function get_font():String {
        return _textFormat.font;
    }

    @:noCompletion
    private function set_font(value:String):String {
        _textFormat.font = value;
        textField.embedFonts = true;
        textField.defaultTextFormat = _textFormat;
        textField.setTextFormat(_textFormat);
        requestLayout();
        return value;
    }

    @:noCompletion
    private function get_text():String {
        return textField.text;
    }

    @:noCompletion
    private function set_text(value:String):String {
        textField.text = value;
        requestLayout();
        return value;
    }
}
