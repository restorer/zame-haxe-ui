package org.zamedev.ui.internal;

import openfl.text.TextField;

#if js

import js.Browser;
import js.html.Element;
import openfl.text.TextFormat;

class TextFieldExt extends TextField {
    private static var _divExt:Element = null;
    private static var _isFirefox:Bool = false;

    private var _isTextHeightDirty:Bool;
    private var _textHeight:Float;

    public function new() {
        super();

        if (_divExt == null) {
            _divExt = Browser.document.createElement("div");
            _divExt.style.position = "absolute";
            _divExt.style.top = "110%";
            Browser.document.body.appendChild(_divExt);

            _isFirefox = (Browser.navigator.userAgent.toLowerCase().indexOf("firefox") >= 0);
        }

        _isTextHeightDirty = true;
        _textHeight = 0.0;

        _updateJsFont(__textFormat);
    }

    @:noCompletion
    override private function __getFont(format:TextFormat):String {
        return cast(format)._jsFont;
    }

    @:noCompletion
    override public function set_text(value:String):String {
        if (__isHTML || __text != value) {
            _isTextHeightDirty = true;
        }

        return super.set_text(value);
    }

    @:noCompletion
    override private function set_htmlText(value:String):String {
        if (!__isHTML || __text != value) {
            _isTextHeightDirty = true;
        }

        super.set_htmlText(value);

        if (__ranges != null) {
            for (range in __ranges) {
                _updateJsFont(range.format);
            }
        }

        return value;
    }

    override public function setTextFormat(format:TextFormat, beginIndex:Int = 0, endIndex:Int = 0):Void {
        super.setTextFormat(format, beginIndex, endIndex);

        if (format.font != __textFormat.font
            || format.size != __textFormat.size
            || format.bold != __textFormat.bold
            || format.italic != __textFormat.italic
            || format.leading != __textFormat.leading
        ) {
            _updateJsFont(__textFormat);
            _isTextHeightDirty = true;
        }
    }

    @:noCompletion
    override private function set_defaultTextFormat(value:TextFormat):TextFormat {
        var update = (value.font != __textFormat.font
            || value.size != __textFormat.size
            || value.bold != __textFormat.bold
            || value.italic != __textFormat.italic
            || value.leading != __textFormat.leading
        );

        super.set_defaultTextFormat(value);

        if (update) {
            _updateJsFont(__textFormat);
        }

        return value;
    }

    @:noCompletion
    override public function get_textHeight():Float {
        if (_isTextHeightDirty) {
            _divExt.style.setProperty("font", __getFont(__textFormat), null);
            _divExt.style.width = Std.string(__width + 4) + "px";
            _divExt.innerHTML = __text;

            if (_isFirefox && __textFormat.size >= 22) {
                _textHeight = _divExt.clientHeight;
            } else {
                _textHeight = _divExt.clientHeight + __textFormat.size * 0.185;
            }

            _isTextHeightDirty = false;
        }

        return _textHeight;
    }

    private function _updateJsFont(format:TextFormat) {
        var jsFont = format.italic ? "italic " : "normal ";
        jsFont += "normal ";
        jsFont += format.bold ? "bold " : "normal ";
        jsFont += format.size + "px";

        if (_isFirefox) {
            jsFont += "/" + (format.size + format.leading) + "px ";
        } else {
            jsFont += "/" + (format.size + format.leading + 4) + "px ";
        }

        jsFont += "'" + switch (format.font) {
            case "_sans": "sans-serif";
            case "_serif": "serif";
            case "_typewriter": "monospace";
            default: format.font;
        }

        jsFont += "'";
        cast(format)._jsFont = jsFont;
    }
}

#else

typedef TextFieldExt = TextField;

#end
