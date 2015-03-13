package org.zamedev.ui.internal;

import openfl.text.TextField;

#if js

import js.Browser;
import js.html.Element;
import openfl.text.TextFormat;

#if !dom
    import openfl._internal.renderer.RenderSession;
#end

using StringTools;

class TextFieldExt extends TextField {
    private static var _divExt:Element = null;
    private static var _isFirefox:Bool = false;

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

        if (_divExt == null) {
            _divExt = Browser.document.createElement("div");
            _divExt.style.position = "absolute";
            _divExt.style.top = "0";
            _divExt.style.left = "0";
            _divExt.style.visibility = "hidden";
            Browser.document.body.appendChild(_divExt);

            _isFirefox = (Browser.navigator.userAgent.toLowerCase().indexOf("firefox") >= 0);
        }

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

        _updateJsFont(__textFormat);
    }

    @:noCompletion
    override private function __getFont(format:TextFormat):String {
        return cast(format)._jsFont;
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
            _updateJsFont(__textFormat);
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
        _reMeasure();
        return _textWidth;
    }

    @:noCompletion
    override public function get_textHeight():Float {
        _reMeasure();

        #if dom
            return _textHeight;
        #else
            return (_isInRender ? _lineHeight : _textHeight);
        #end
    }

    private function _reMeasure():Void {
        if (_isMeasurementsDirty) {
            _divExt.style.setProperty("font", __getFont(__textFormat), null);
            _divExt.style.width = "auto";
            _divExt.style.height = "auto";

            #if !dom
                _divExt.innerHTML = "giItT1WQy@!-/#";
                _lineHeight = _divExt.clientHeight;
            #end

            _divExt.innerHTML = _escapedText;
            _textWidth = _divExt.clientWidth + 1;
            _divExt.style.width = Std.string(__width) + "px";

            #if dom
                _textHeight = _divExt.clientHeight;
            #else
                if (_isFirefox && __textFormat.size >= 22) {
                    _textHeight = _divExt.clientHeight;
                } else {
                    _textHeight = _divExt.clientHeight + __textFormat.size * 0.185;
                }
            #end

            _isMeasurementsDirty = false;
        }
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

    #if !dom
        @:noCompletion
        override public function __renderCanvas(renderSession:RenderSession):Void {
            _isInRender = true;
            super.__renderCanvas(renderSession);
            _isInRender = false;
        }
    #end
}

#else

typedef TextFieldExt = TextField;

#end
