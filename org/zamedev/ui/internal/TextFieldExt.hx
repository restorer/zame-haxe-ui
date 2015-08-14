package org.zamedev.ui.internal;

import openfl.text.TextField;

#if (js && dom)

import js.Browser;
import js.html.DOMElement;
import openfl.text.TextFormat;

#if (openfl <= "3.2.2")
    import openfl._internal.renderer.dom.DOMTextField;
#end

using StringTools;

class TextFieldExt extends TextField {
    private var _escapedText:String;
    private var _originalText:String;

    #if (openfl <= "3.2.2")
        private var _isMeasurementsDirty:Bool;
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
    override public function get_text():String {
        return _originalText;
    }

    @:noCompletion
    override public function set_text(value:String):String {
        if (__isHTML || _originalText != value) {
            _originalText = value;
            _escapedText = value.htmlEscape().replace(" ", "&nbsp;").replace("\n", "<br />");

            #if (openfl <= "3.2.2")
                _isMeasurementsDirty = true;
            #end
        }

        super.set_text(_escapedText);
        return value;
    }

    @:noCompletion
    override private function set_htmlText(value:String):String {
        if (!__isHTML || _originalText != value) {
            _originalText = value;
            _escapedText = value;

            #if (openfl <= "3.2.2")
                _isMeasurementsDirty = true;
            #end
        }

        super.set_htmlText(_escapedText);
        return value;
    }

    #if (openfl <= "3.2.2")
        override public function setTextFormat(format:TextFormat, beginIndex:Int = 0, endIndex:Int = 0):Void {
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
        override private function set_defaultTextFormat(value:TextFormat):TextFormat {
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
        override public function set_width(value:Float):Float {
            _isMeasurementsDirty = true;
            return super.set_width(value);
        }

        @:noCompletion
        override public function set_height(value:Float):Float {
            _isMeasurementsDirty = true;
            return super.set_height(value);
        }

        @:noCompletion
        override public function get_textWidth():Float {
            DOMTextFieldExt.measureText(this);
            return __measuredWidth;
        }

        @:noCompletion
        override public function get_textHeight():Float {
            DOMTextFieldExt.measureText(this);
            return __measuredHeight;
        }
    #end
}

#if (openfl <= "3.2.2")
    @:access(openfl.text.TextField)
    class DOMTextFieldExt {
        private static var _divExt:DOMElement = null;

        private static function initialize():Void {
            _divExt = Browser.document.createElement("div");
            _divExt.style.position = "absolute";
            _divExt.style.top = "0";
            _divExt.style.left = "0";
            _divExt.style.visibility = "hidden";
            _divExt.style.setProperty("pointer-events", "none", null);
            Browser.document.body.appendChild(_divExt);
        }

        public static function measureText(textField:TextFieldExt):Void {
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
