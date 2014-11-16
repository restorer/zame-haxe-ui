package org.zamedev.ui.view;

import openfl.text.TextField;
import openfl.text.TextFormat;
import org.zamedev.ui.res.TypedValue;

class TextView extends View {
    private var _textFormat:TextFormat;
    private var textField:TextField;

    public var textColor(get, set):Null<UInt>;
    public var textSize(get, set):Null<Float>;
    public var font(get, set):String;
    public var text(get, set):String;

    public function new() {
        super();

        _textFormat = new TextFormat();
        textField = new TextField();

        textField.selectable = false;
        textField.defaultTextFormat = _textFormat;

        addChild(textField);

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

    override public function onMeasure(child:View = null):Void {
        textField.width = 1000;
        textField.height = 1000;

        #if js
            textField.width = textField.textWidth;

            if (_textFormat.size == null) {
                textField.height = textField.textHeight;
            } else if (_textFormat.size <= 16) {
                textField.height = _textFormat.size * 1.185;
            } else {
                textField.height = _textFormat.size;
            }
        #else
            #if android
                textField.width = textField.textWidth * 1.1;
            #else
                textField.width = textField.textWidth + 4;
            #end

            textField.height = textField.textHeight;
        #end
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
        measure();
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
        measure();
        return value;
    }

    @:noCompletion
    private function get_text():String {
        return textField.text;
    }

    @:noCompletion
    private function set_text(value:String):String {
        textField.text = value;
        measure();
        return value;
    }
}
