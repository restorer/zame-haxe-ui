package org.zamedev.ui.internal;

import openfl.text.TextField;

#if js

import js.Browser;
import js.html.DOMElement;
import openfl._internal.renderer.RenderSession;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

#if dom
    import openfl._internal.renderer.dom.DOMRenderer;
#end

using StringTools;

class TextFieldExt extends TextField {
    private var _isMeasurementsDirty:Bool;
    private var _textWidth:Float;
    private var _textHeight:Float;
    private var _escapedText:String;

    #if dom
        private var _originalText:String;
    #else
        private var _lineHeight:Float;
        private var _isInRender:Bool;
    #end

    public function new() {
        super();

        _isMeasurementsDirty = true;
        _textWidth = 0.0;
        _textHeight = 0.0;
        _escapedText = "";

        #if dom
            _originalText = "";
        #else
            _lineHeight = 0.0;
            _isInRender = false;
        #end

        DOMTextFieldExt.updateJsFont(__textFormat);
    }

    #if dom
        @:noCompletion
        override public function get_text():String {
            return _originalText;
        }
    #end

    @:noCompletion
    override public function set_text(value:String):String {
        if (__isHTML || __text != value) {
            _escapedText = value.htmlEscape().replace(" ", "&nbsp;").replace("\n", "<br />");
            _isMeasurementsDirty = true;
        }

        #if dom
            _originalText = value;
            super.set_text(_escapedText);
            return value;
        #else
            return super.set_text(value);
        #end
    }

    @:noCompletion
    override private function set_htmlText(value:String):String {
        if (!__isHTML || __text != value) {
            _escapedText = value;
            _isMeasurementsDirty = true;
        }

        #if dom
            _originalText = value;
        #end

        super.set_htmlText(value);

        if (__ranges != null) {
            for (range in __ranges) {
                DOMTextFieldExt.updateJsFont(range.format);
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
            DOMTextFieldExt.updateJsFont(__textFormat);
            _isMeasurementsDirty = true;
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
            DOMTextFieldExt.updateJsFont(__textFormat);
        }

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
        return _textWidth;
    }

    @:noCompletion
    override public function get_textHeight():Float {
        DOMTextFieldExt.measureText(this);

        #if dom
            return _textHeight;
        #else
            return (_isInRender ? _lineHeight : _textHeight);
        #end
    }

    #if dom
        @:noCompletion
        public override function __renderDOM(renderSession:RenderSession):Void {
            DOMTextFieldExt.render(this, renderSession);
        }
    #else
        @:noCompletion
        override public function __renderCanvas(renderSession:RenderSession):Void {
            _isInRender = true;
            super.__renderCanvas(renderSession);
            _isInRender = false;
        }
    #end
}

@:access(openfl.text.TextField)
class DOMTextFieldExt {
    private static var _divExt:DOMElement = null;
    private static var _isFirefox:Bool = false;

    private static function initialize():Void {
        _divExt = Browser.document.createElement("div");
        _divExt.style.position = "absolute";
        _divExt.style.top = "0";
        _divExt.style.left = "0";
        _divExt.style.visibility = "hidden";
        Browser.document.body.appendChild(_divExt);

        _isFirefox = (Browser.navigator.userAgent.toLowerCase().indexOf("firefox") >= 0);
    }

    public static function getFont(format:TextFormat):String {
        return untyped format._jsFont;
    }

    public static function updateJsFont(format:TextFormat) {
        if (_divExt == null) {
            initialize();
        }

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
        untyped format._jsFont = jsFont;
    }

    public static function measureText(textField:TextFieldExt):Void {
        if (!textField._isMeasurementsDirty) {
            return;
        }

        if (_divExt == null) {
            initialize();
        }

        _divExt.style.setProperty("font", getFont(textField.__textFormat), null);
        _divExt.style.width = "auto";
        _divExt.style.height = "auto";

        #if !dom
            _divExt.innerHTML = "giItT1WQy@!-/#";
            textField._lineHeight = _divExt.clientHeight;
        #end

        _divExt.innerHTML = textField._escapedText;
        textField._textWidth = _divExt.clientWidth + 1;
        _divExt.style.width = Std.string(textField.__width) + "px";

        #if dom
            textField._textHeight = _divExt.clientHeight;
        #else
            if (_isFirefox && textField.__textFormat.size >= 22) {
                textField._textHeight = _divExt.clientHeight;
            } else {
                textField._textHeight = _divExt.clientHeight + textField.__textFormat.size * 0.185;
            }
        #end

        textField._isMeasurementsDirty = false;
    }

    #if dom
        public static inline function render(textField:TextFieldExt, renderSession:RenderSession):Void {
            if (textField.stage != null && textField.__worldVisible && textField.__renderable) {
                if (textField.__dirty || textField.__div == null) {
                    if (textField.__text != "" || textField.background || textField.border) {
                        if (textField.__div == null) {
                            textField.__div = cast Browser.document.createElement("div");
                            DOMRenderer.initializeElement(textField, textField.__div, renderSession);
                            textField.__style.setProperty("cursor", "inherit", null);
                        }

                        var style = textField.__style;
                        textField.__div.innerHTML = textField.__text;

                        if (textField.background) {
                            style.setProperty("background-color", "#" + StringTools.hex(textField.backgroundColor, 6), null);
                        } else {
                            style.removeProperty("background-color");
                        }

                        if (textField.border) {
                            style.setProperty("border", "solid 1px #" + StringTools.hex(textField.borderColor, 6), null);
                        } else {
                            style.removeProperty("border");
                        }

                        style.setProperty("font", getFont(textField.__textFormat), null);
                        style.setProperty("color", "#" + StringTools.hex(textField.__textFormat.color, 6), null);

                        if (textField.autoSize != TextFieldAutoSize.NONE) {
                            style.setProperty("width", "auto", null);
                        } else {
                            style.setProperty("width", textField.__width + "px", null);
                        }

                        style.setProperty("height", textField.__height + "px", null);

                        switch (textField.__textFormat.align) {
                            case TextFormatAlign.CENTER:
                                style.setProperty("text-align", "center", null);

                            case TextFormatAlign.RIGHT:
                                style.setProperty("text-align", "right", null);

                            default:
                                style.setProperty("text-align", "left", null);
                        }

                        textField.__dirty = false;
                    } else if (textField.__div != null) {
                        renderSession.element.removeChild(textField.__div);
                        textField.__div = null;
                    }
                }

                if (textField.__div != null) {
                    DOMRenderer.applyStyle(textField, renderSession, true, true, false);
                }
            } else if (textField.__div != null) {
                renderSession.element.removeChild(textField.__div);
                textField.__div = null;
                textField.__style = null;
            }
        }
    #end
}

#else

typedef TextFieldExt = TextField;

#end
