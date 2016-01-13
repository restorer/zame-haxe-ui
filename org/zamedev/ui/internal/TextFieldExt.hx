package org.zamedev.ui.internal;

import openfl.text.TextField;

#if (js && dom)

import js.Browser;
import js.html.DOMElement;
import openfl.events.MouseEvent;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;

#if (openfl <= "3.2.2")
    import openfl._internal.renderer.dom.DOMTextField;
#else
    import js.html.KeyboardEvent;
    import openfl._internal.renderer.RenderSession;
    import openfl._internal.text.TextFormatRange;
#end

using StringTools;

class TextFieldExt extends TextField {
    private var _escapedText : String;
    private var _originalText : String;

    #if (openfl <= "3.2.2")
        private var _isMeasurementsDirty : Bool;
    #end

    public function new() {
        super();

        _escapedText = "";
        _originalText = "";

        #if (openfl <= "3.2.2")
            _isMeasurementsDirty = true;
        #end
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

            #if (openfl <= "3.2.2")
                _isMeasurementsDirty = true;
            #end
        }

        #if (openfl > "3.2.2")
            setHtmlTextInternal(_escapedText);
        #else
            super.set_text(_escapedText);
        #end

        return value;
    }

    @:noCompletion
    override private function set_htmlText(value : String) : String {
        if (!__isHTML || _originalText != value) {
            _originalText = value;
            _escapedText = value;

            #if (openfl <= "3.2.2")
                _isMeasurementsDirty = true;
            #end
        }

        #if (openfl > "3.2.2")
            setHtmlTextInternal(_escapedText);
        #else
            super.set_htmlText(_escapedText);
        #end

        return value;
    }

    #if (openfl > "3.2.2")
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

            return __textEngine.text = value;
        }
    #end

    #if (openfl <= "3.2.2")
        override public function setTextFormat(format : TextFormat, beginIndex : Int = 0, endIndex : Int = 0) : Void {
            if (format.font != __textFormat.font
                || format.size != __textFormat.size
                || format.bold != __textFormat.bold
                || format.italic != __textFormat.italic
                || format.leading != __textFormat.leading
            ) {
                _isMeasurementsDirty = true;
            }

            super.setTextFormat(format, beginIndex, endIndex);
        }

        @:noCompletion
        override private function set_defaultTextFormat(value : TextFormat) : TextFormat {
            if (value.font != __textFormat.font
                || value.size != __textFormat.size
                || value.bold != __textFormat.bold
                || value.italic != __textFormat.italic
                || value.leading != __textFormat.leading
            ) {
                _isMeasurementsDirty = true;
            }

            super.set_defaultTextFormat(value);
            return value;
        }

        @:noCompletion
        override public function set_width(value : Float) : Float {
            _isMeasurementsDirty = true;
            return super.set_width(value);
        }

        @:noCompletion
        override public function set_height(value : Float) : Float {
            _isMeasurementsDirty = true;
            return super.set_height(value);
        }

        @:noCompletion
        override public function get_textWidth() : Float {
            DOMTextFieldExt.measureText(this);
            return __measuredWidth;
        }

        @:noCompletion
        override public function get_textHeight() : Float {
            DOMTextFieldExt.measureText(this);
            return __measuredHeight;
        }
    #end

    #if (openfl > "3.2.2")
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
                }
            }
        }

        private function handleKeyEventInternal(event : KeyboardEvent) : Void {
            if (event.keyCode == 9) {
                event.preventDefault();
            }
        }
    #end
}

#if (openfl <= "3.2.2")
    @:access(openfl.text.TextField)
    class DOMTextFieldExt {
        private static var _divExt : DOMElement = null;

        private static function initialize() : Void {
            _divExt = Browser.document.createElement("div");
            _divExt.style.position = "absolute";
            _divExt.style.top = "0";
            _divExt.style.left = "0";
            _divExt.style.visibility = "hidden";
            _divExt.style.setProperty("pointer-events", "none", null);
            Browser.document.body.appendChild(_divExt);
        }

        public static function measureText(textField : TextFieldExt) : Void {
            if (!textField._isMeasurementsDirty) {
                return;
            }

            if (_divExt == null) {
                initialize();
            }

            _divExt.style.setProperty("font", DOMTextField.getFont(textField.__textFormat), null);
            _divExt.style.width = "auto";
            _divExt.style.height = "auto";
            _divExt.innerHTML = textField._escapedText;

            textField.__measuredWidth = _divExt.clientWidth;
            textField.__measuredHeight = _divExt.clientHeight;
            textField._isMeasurementsDirty = false;
        }
    }
#end

#else

typedef TextFieldExt = TextField;

#end
