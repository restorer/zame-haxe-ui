package org.zamedev.ui.internal;

import openfl.text.TextField;

#if (js && dom)

import js.Browser;
import js.html.DOMElement;
import openfl.events.MouseEvent;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import js.html.KeyboardEvent;
import openfl._internal.renderer.RenderSession;
import openfl._internal.text.TextFormatRange;

using StringTools;

class TextFieldExt extends TextField {
    private var _escapedText : String;
    private var _originalText : String;

    public function new() {
        super();

        _escapedText = "";
        _originalText = "";
    }

    @:noCompletion
    override public function get_text() : String {
        if (type == TextFieldType.INPUT) {
            _escapedText = htmlText;

            _originalText = ~/<[^>]*>/g.replace(super.get_text(), "");
            _originalText = _originalText.replace("\n", "");
        }

        return _originalText;
    }

    @:noCompletion
    override public function set_text(value : String) : String {
        if (__isHTML || _originalText != value) {
            _originalText = value;
            _escapedText = value.htmlEscape().replace(" ", "&nbsp;").replace("\n", "<br>");
        }

        setHtmlTextInternal(_escapedText);
        return value;
    }

    @:noCompletion
    override private function set_htmlText(value : String) : String {
        if (!__isHTML || _originalText != value) {
            _originalText = value;
            _escapedText = value;
        }

        setHtmlTextInternal(_escapedText);
        return value;
    }

    private function setHtmlTextInternal(value : String) : String {
        if (!__isHTML || __textEngine.text != value) {
            __dirty = true;
            __layoutDirty = true;
        }

        __isHTML = true;

        value = ~/<br[^\/>]*\/?>/g.replace(value, "\n");
        value = value.replace("&nbsp;", " ");

        value = new EReg ("<.*?>", "g").replace(value, "");

        if (__textEngine.textFormatRanges.length > 1) {
            __textEngine.textFormatRanges.splice(1, __textEngine.textFormatRanges.length - 1);
        }

        var range = __textEngine.textFormatRanges[0];
        range.format = __textFormat;
        range.start = 0;
        range.end = value.length;

        __text = value;
        return __textEngine.text = value;
    }

    @:noCompletion
    override private function this_onMouseDown(event : MouseEvent) : Void {
        if (type == TextFieldType.INPUT) {
            return;
        }

        super.this_onMouseDown(event);
    }

    @:noCompletion
    override public function __renderDOM(renderSession : RenderSession) : Void {
        var shouldUpdate = (stage != null
            && __worldVisible
            && __renderable
            && (__dirty || __div == null)
            && (__textEngine.text != "" || __textEngine.background || __textEngine.border || __textEngine.type == TextFieldType.INPUT)
        );

        var prevText = __textEngine.text;
        __textEngine.text = _escapedText;
        super.__renderDOM(renderSession);
        __textEngine.text = prevText;

        if (__div != null && shouldUpdate) {
            __div.removeEventListener("keydown", handleKeyEventInternal, false);

            if (type == TextFieldType.INPUT) {
                __div.style.setProperty("-webkit-user-select", "text", null);
                __div.style.setProperty("-moz-user-select", "text", null);
                __div.style.setProperty("-ms-user-select", "text", null);
                __div.style.setProperty("-o-user-select", "text", null);
                __div.addEventListener("keydown", handleKeyEventInternal, false);
            } else {
                __div.style.setProperty("-webkit-user-select", "none", null);
                __div.style.setProperty("-moz-user-select", "none", null);
                __div.style.setProperty("-ms-user-select", "none", null);
                __div.style.setProperty("-o-user-select", "none", null);

                // to prevent blurred fonts on macOS
                __div.style.setProperty("-webkit-font-smoothing", "antialiased"); // "subpixel-antialiased" is by default
                __div.style.setProperty("-moz-osx-font-smoothing", "grayscale");
            }
        }
    }

    private function handleKeyEventInternal(event : KeyboardEvent) : Void {
        if (event.keyCode == 9) {
            event.preventDefault();
        }
    }
}

#else

typedef TextFieldExt = TextField;

#end
