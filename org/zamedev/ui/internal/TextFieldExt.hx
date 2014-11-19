package org.zamedev.ui.internal;

import openfl.text.TextField;

#if js

import openfl.text.TextFormat;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.CSSStyleDeclaration;
import js.html.DivElement;
import js.html.Element;
import js.Browser;

class TextFieldExt extends TextField {
    private static var _divExt:Element = null;
    private static var _isFirefox:Bool = false;

    public function new() {
        super();

        if (_divExt == null) {
            _divExt = Browser.document.createElement("div");
            _divExt.style.position = "absolute";
            _divExt.style.top = "110%";
            Browser.document.body.appendChild(_divExt);

            _isFirefox = (Browser.navigator.userAgent.toLowerCase().indexOf("firefox") >= 0);
        }
    }

    @:noCompletion
    override private function __getFont(format:TextFormat):String {
        var font = format.italic ? "italic " : "normal ";
        font += "normal ";
        font += format.bold ? "bold " : "normal ";
        font += format.size + "px";

        if (_isFirefox) {
            font += "/" + (format.size + format.leading) + "px ";
        } else {
            font += "/" + (format.size + format.leading + 4) + "px ";
        }

        font += "'" + switch (format.font) {
            case "_sans": "sans-serif";
            case "_serif": "serif";
            case "_typewriter": "monospace";
            default: format.font;
        }

        font += "'";
        return font;
    }

    @:noCompletion
    override public function get_textHeight():Float {
        _divExt.style.setProperty("font", __getFont(__textFormat), null);
        _divExt.style.width = Std.string(__width + 4) + "px";
        _divExt.innerHTML = __text;

        if (_isFirefox && __textFormat.size >= 16) {
            return _divExt.clientHeight;
        } else {
            return _divExt.clientHeight + __textFormat.size * 0.185;
        }
    }
}

#else

typedef TextFieldExt = TextField;

#end
