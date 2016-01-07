package org.zamedev.ui.view;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.events.FocusEvent;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import org.zamedev.ui.Context;
import org.zamedev.ui.graphics.Color;
import org.zamedev.ui.graphics.FontExt;
import org.zamedev.ui.graphics.TextAlignExt;
import org.zamedev.ui.internal.TextFieldExt;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.Styleable;
import org.zamedev.ui.view.TextView;

using StringTools;

#if bitmapFont
    import bitmapFont.BitmapTextAlign;
    import bitmapFont.BitmapTextField;
#end

class TextView extends View {
    private var _font:FontExt;
    private var _textColor:Null<Int>;
    private var _textSize:Null<Int>;
    private var _textLeading:Null<Int>;
    private var _textAlign:TextAlignExt;
    private var _text:String;
    private var _htmlText:String;
    private var _editable:Bool;
    private var _displayAsPassword:Bool;

    private var _textField:TextFieldExt;
    private var _textFormat:TextFormat;
    private var _listenersAdded:Bool;

    #if (!flash && !webgl && !dom && !(native && openfl_legacy) && !debug_ui_noTextViewCache)
        private var _cachedBitmap:Bitmap;
    #end

    #if bitmapFont
        private var _bitmapTextField:BitmapTextField;
    #end

    public var font(get, set):FontExt;
    public var textColor(get, set):Null<Int>;
    public var textSize(get, set):Null<Int>;
    public var textLeading(get, set):Null<Int>;
    public var textAlign(get, set):TextAlignExt;
    public var text(get, set):String;
    public var htmlText(never, set):String;
    public var editable(get, set):Bool;
    public var displayAsPassword(get, set):Bool;

    @:keep
    public function new(context:Context) {
        super(context);

        _font = null;
        _textColor = null;
        _textSize = null;
        _textLeading = null;
        _textAlign = null;
        _text = null;
        _htmlText = null;
        _editable = false;
        _displayAsPassword = false;

        _textField = null;
        _textFormat = null;
        _listenersAdded = false;

        #if (!flash && !webgl && !dom && !(native && openfl_legacy) && !debug_ui_noTextViewCache)
            _cachedBitmap = null;
        #end

        #if bitmapFont
            _bitmapTextField = null;
        #end
    }

    private function reConfigure():Void {
        if (_textField != null && _textField.parent != null) {
            if (_editable) {
                updateEditedText();

                if (_listenersAdded) {
                    _textField.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
                    _textField.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
                    _listenersAdded = false;
                }
            }

            _sprite.removeChild(_textField);
        }

        #if (!flash && !webgl && !dom && !(native && openfl_legacy) && !debug_ui_noTextViewCache)
            if (_cachedBitmap != null && _cachedBitmap.parent != null) {
                _sprite.removeChild(_cachedBitmap);
            }
        #end

        #if bitmapFont
            if (_bitmapTextField != null && _bitmapTextField.parent != null) {
                _sprite.removeChild(_bitmapTextField);
            }
        #end

        if (_font == null) {
            return;
        }

        #if bitmapFont
            if (_font.bitmapFont != null) {
                if (_bitmapTextField == null) {
                    _bitmapTextField = new BitmapTextField(_font.bitmapFont, "", null, true);
                } else {
                    _bitmapTextField.font = _font.bitmapFont;
                }

                updateBitmapTextFieldColor();
                _bitmapTextField.size = (_textSize == null ? 1.0 : _textSize / _font.bitmapFont.size);
                _bitmapTextField.lineSpacing = (_textLeading == null ? 0 : _textLeading);
                _bitmapTextField.alignment = getAlignForBitmapTextField();

                if (_text != null) {
                    _bitmapTextField.text = _text;
                } else if (_htmlText != null) {
                    _bitmapTextField.text = _htmlText;
                }

                _sprite.addChild(_bitmapTextField);
                return;
            }
        #end

        if (_font.ttfFontName != null) {
            if (_textField == null) {
                _textField = new TextFieldExt();
                _textField.embedFonts = true;

                #if debug_ui
                    _textField.borderColor = 0x800000;
                    _textField.border = true;
                #end

                _textFormat = new TextFormat();

                #if (!flash && !webgl && !dom && !(native && openfl_legacy) && !debug_ui_noTextViewCache)
                    _cachedBitmap = new Bitmap();
                #end
            }

            if (_editable) {
                _textField.selectable = true;
                _textField.wordWrap = false;
                _textField.multiline = false;
                _textField.type = TextFieldType.INPUT;
            } else {
                _textField.selectable = false;
                _textField.wordWrap = true;
                _textField.multiline = true;
                _textField.type = TextFieldType.DYNAMIC;
            }

            #if (!flash && !webgl && !dom && !(native && openfl_legacy) && !debug_ui_noTextViewCache)
                if (_editable) {
                    _sprite.addChild(_textField);
                } else {
                    _sprite.addChild(_cachedBitmap);
                }
            #else
                _sprite.addChild(_textField);
            #end

            _textFormat.font = _font.ttfFontName;
            _textFormat.color = _textColor;
            _textFormat.size = _textSize;
            _textFormat.leading = (_textLeading == null ? null : _textLeading #if html5 - 4 #end );
            _textFormat.align = getAlignForTextField();

            _textField.defaultTextFormat = _textFormat;
            _textField.setTextFormat(_textFormat);
            _textField.displayAsPassword = _displayAsPassword;

            if (_text != null) {
                _textField.text = _text;
            } else if (_htmlText != null) {
                _textField.htmlText = getHtmlTextForTextField();
            }

            if (_editable && !_listenersAdded) {
                _textField.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
                _textField.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
                _listenersAdded = true;
            }

            #if (!flash && !webgl && !dom && !(native && openfl_legacy) && !debug_ui_noTextViewCache)
                if (!_editable) {
                    updateCache();
                }
            #end
        }
    }

    private function getAlignForTextField(): #if legacy String #else TextFormatAlign #end {
        if (_textAlign == null) {
            return null;
        }

        switch (_textAlign) {
            case LEFT:
                return TextFormatAlign.LEFT;

            case RIGHT:
                return TextFormatAlign.RIGHT;

            case CENTER:
                return TextFormatAlign.CENTER;

            case JUSTIFY:
                return TextFormatAlign.JUSTIFY;
        }
    }

    private function getHtmlTextForTextField():String {
        if (_htmlText == null) {
            return null;
        }

        var result = ~/"@(font\/[^"]+)"/g.map(_htmlText, function(re:EReg):String {
            #if bitmapFont
                if (_font.bitmapFont != null) {
                    return re.matched(0);
                }
            #end

            var resId = _context.resourceManager.findIdByName(re.matched(1));
            var font =_context.resourceManager.getFont(resId == null ? 0 : resId);

            return "\"" + font.ttfFontName + "\"";
        });

        result = ~/"@(color\/[^"]+)"/g.map(result, function(re:EReg):String {
            var resId = _context.resourceManager.findIdByName(re.matched(1));
            var color = _context.resourceManager.getColor(resId == null ? 0 : resId);

            return "\"" + Color.toHexString(color) + "\"";
        });

        result = ~/"@(dimen\/[^"]+)"/g.map(result, function(re:EReg):String {
            var resId = _context.resourceManager.findIdByName(re.matched(1));
            var dimen = _context.resourceManager.getDimension(resId == null ? 0 : resId);

            return "\"" + computeDimension(dimen, true) + "\"";
        });

        result = ~/[\n]?<br[^\/>]*\/?>[\n]?/g.replace(result, "<br>");
        result = result.replace("\n", " ");

        return result;
    }

    #if bitmapFont
        private function updateBitmapTextFieldColor():Void {
            if (_textColor == null) {
                _bitmapTextField.useTextColor = false;
            } else {
                _bitmapTextField.useTextColor = true;
                _bitmapTextField.textColor = (0xFF000000 | _textColor);
            }
        }

        private function getAlignForBitmapTextField():BitmapTextAlign {
            if (_textAlign == null) {
                return BitmapTextAlign.LEFT;
            }

            switch (_textAlign) {
                case LEFT:
                    return BitmapTextAlign.LEFT;

                case RIGHT:
                    return BitmapTextAlign.RIGHT;

                case CENTER | JUSTIFY:
                    return BitmapTextAlign.CENTER;
            }
        }
    #end

    override private function _inflate(attId:Styleable, value:Dynamic):Bool {
        if (super._inflate(attId, value)) {
            return true;
        }

        switch (attId) {
            case Styleable.textColor:
                textColor = cast value;
                return true;

            case Styleable.textSize:
                textSize = Std.int(computeDimension(cast value, true));
                return true;

            case Styleable.textLeading:
                textLeading = Std.int(computeDimension(cast value, true));
                return true;

            case Styleable.textAlign:
                textAlign = cast value;
                return true;

            case Styleable.font:
                font = cast value;
                return true;

            case Styleable.text:
                text = cast value;
                return true;

            case Styleable.htmlText:
                htmlText = cast value;
                return true;

            case Styleable.displayAsPassword:
                displayAsPassword = cast value;
                return true;

            default:
                return false;
        }
    }

    override private function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
        if (super.measureAndLayout(widthSpec, heightSpec)) {
            return true;
        }

        if (_font == null) {
            _width = 0;
            _height = 0;
            return true;
        }

        #if bitmapFont
            if (_font.bitmapFont != null) {
                switch (widthSpec) {
                    case MeasureSpec.UNSPECIFIED:
                        _bitmapTextField.autoSize = true;
                        _width = _bitmapTextField.textWidth;

                    case MeasureSpec.EXACT(size):
                        _bitmapTextField.autoSize = false;
                        _bitmapTextField.width = size;
                        _width = size;

                    case MeasureSpec.AT_MOST(size):
                        _bitmapTextField.autoSize = false;
                        _bitmapTextField.width = size;
                        _width = Math.min(size, _bitmapTextField.textWidth);
                        _bitmapTextField.width = _width;
                }

                _height = _bitmapTextField.textHeight;
            }
        #end

        if (_font.ttfFontName != null) {
            _textField.wordWrap = false;
            _textField.autoSize = TextFieldAutoSize.LEFT;

            switch (widthSpec) {
                case MeasureSpec.UNSPECIFIED:
                    _width = (_textField.textWidth + #if flash 8 #else 4 #end);

                case MeasureSpec.AT_MOST(size):
                    _width = Math.min(size, (_textField.textWidth + #if flash 8 #else 4 #end));
                    _textField.wordWrap = true;
                    _textField.width = size;

                case MeasureSpec.EXACT(size):
                    _width = size;
                    _textField.wordWrap = true;
                    _textField.width = size;
            }

            switch (heightSpec) {
                case MeasureSpec.UNSPECIFIED:
                    _height = _textField.textHeight + 4;

                case MeasureSpec.AT_MOST(size):
                    _height = Math.min(size, _textField.textHeight + 4);

                case MeasureSpec.EXACT(size):
                    _height = size;
            }

            #if html5
                // if (_textLeading != null && _textField.textHeight > (_textSize == null ? 0 : _textSize) + _textLeading) {

                if (_textLeading != null && _textField.numLines > 1) {
                    _height += _textLeading;
                }
            #end

            switch (widthSpec) {
                case MeasureSpec.AT_MOST(_) | MeasureSpec.EXACT(_):
                    _textField.autoSize = TextFieldAutoSize.NONE;

                default:
            }

            _textField.height = _height;

            #if (!flash && !webgl && !dom && !(native && openfl_legacy) && !debug_ui_noTextViewCache)
                if (!_editable) {
                    updateCache();
                }
            #end
        }

        return true;
    }

    #if (!flash && !webgl && !dom && !(native && openfl_legacy) && !debug_ui_noTextViewCache)
        private function updateCache():Void {
            var cachedBitmapData = new BitmapData(
                Std.int(Math.max(1, Math.ceil(_width))),
                Std.int(Math.max(1, Math.ceil(_height))),
                true,
                0
            );

            cachedBitmapData.draw(_textField);
            _cachedBitmap.bitmapData = cachedBitmapData;
            _cachedBitmap.smoothing = true;
        }
    #end

    private function onFocusIn(_):Void {
        if (_textField != null && _textField.stage != null #if !legacy && _textField.stage.focus == _textField #end) {
            dispatchEvent(new FocusEvent(FocusEvent.FOCUS_IN));
        }
    }

    private function onFocusOut(_):Void {
        dispatchEvent(new FocusEvent(FocusEvent.FOCUS_OUT));
    }

    private function updateEditedText():Void {
        _htmlText = null;
        _text = _textField.text;
    }

    @:noCompletion
    private function get_textColor():Null<Int> {
        return _textColor;
    }

    @:noCompletion
    private function set_textColor(value:Null<Int>):Null<Int> {
        if (_textColor != value) {
            _textColor = value;

            if (_font == null) {
                return value;
            }

            #if bitmapData
                if (_font.bitmapFont != null) {
                    updateBitmapTextFieldColor();
                    return value;
                }
            #end

            if (_font.ttfFontName != null) {
                _textFormat.color = value;
                _textField.defaultTextFormat = _textFormat;
                _textField.setTextFormat(_textFormat);

                #if (!flash && !webgl && !dom && !(native && openfl_legacy) && !debug_ui_noTextViewCache)
                    if (!_editable) {
                        updateCache();
                    }
                #end
            }
        }

        return value;
    }

    @:noCompletion
    private function get_textSize():Null<Int> {
        return _textSize;
    }

    @:noCompletion
    private function set_textSize(value:Null<Int>):Null<Int> {
        if (_textSize != value) {
            _textSize = value;

            if (_font == null) {
                return value;
            }

            #if bitmapFont
                if (_font.bitmapFont != null) {
                    _bitmapTextField.size = (value == null ? 1.0 : value / _font.bitmapFont.size);
                    requestLayout();
                    return value;
                }
            #end

            if (_font.ttfFontName != null) {
                _textFormat.size = value;
                _textField.defaultTextFormat = _textFormat;
                _textField.setTextFormat(_textFormat);
                requestLayout();
            }
        }

        return value;
    }

    @:noCompletion
    private function get_textLeading():Null<Int> {
        return _textLeading;
    }

    @:noCompletion
    private function set_textLeading(value:Null<Int>):Null<Int> {
        if (_textLeading != value) {
            _textLeading = value;

            if (_font == null) {
                return value;
            }

            #if bitmapFont
                if (_font.bitmapFont != null) {
                    _bitmapTextField.lineSpacing = (value == null ? 0 : Std.int(value));
                    requestLayout();
                }
            #end

            if (_font.ttfFontName != null) {
                _textFormat.leading = (_textLeading == null ? null : _textLeading #if html5 - 4 #end );
                _textField.defaultTextFormat = _textFormat;
                _textField.setTextFormat(_textFormat);
                requestLayout();
            }
        }

        return value;
    }

    @:noCompletion
    private function get_textAlign():TextAlignExt {
        return _textAlign;
    }

    @:noCompletion
    private function set_textAlign(value:TextAlignExt):TextAlignExt {
        if (_textAlign != value) {
            _textAlign = value;

            if (_font == null) {
                return value;
            }

            #if bitmapFont
                if (_font.bitmapFont != null) {
                    _bitmapTextField.alignment = getAlignForBitmapTextField();
                    return value;
                }
            #end

            if (_font.ttfFontName != null) {
                _textFormat.align = getAlignForTextField();
                _textField.defaultTextFormat = _textFormat;
                _textField.setTextFormat(_textFormat);

                #if (!flash && !webgl && !dom && !(native && openfl_legacy) && !debug_ui_noTextViewCache)
                    if (!_editable) {
                        updateCache();
                    }
                #end
            }
        }

        return value;
    }

    @:noCompletion
    private function get_font():FontExt {
        return _font;
    }

    @:noCompletion
    private function set_font(value:FontExt):FontExt {
        if (!FontExt.equals(_font, value)) {
            _font = value;
            reConfigure();

            /*
            #if native
                if (_font != null && _font.ttfFontName != null) {
                    if (_htmlText != null) {
                        _textField.htmlText = _textField.htmlText;
                    } else {
                        _textField.text = _textField.text;
                    }
                }
            #end
            */

            requestLayout();
        }

        return value;
    }

    @:noCompletion
    private function get_text():String {
        if (_editable && _textField != null) {
            updateEditedText();
        }

        return _text;
    }

    @:noCompletion
    private function set_text(value:String):String {
        if (_text != value || _htmlText != null) {
            _text = value;
            _htmlText = null;

            if (_font == null) {
                return value;
            }

            #if bitmapFont
                if (_font.bitmapFont != null) {
                    _bitmapTextField.text = value;
                    requestLayout();
                    return value;
                }
            #end

            if (_font.ttfFontName != null) {
                _textField.text = value;
                requestLayout();
            }
        }

        return value;
    }

    @:noCompletion
    private function set_htmlText(value:String):String {
        if (_htmlText != value || _text != null) {
            _htmlText = value;
            _text = null;

            if (_font == null) {
                return value;
            }

            #if bitmapFont
                if (_font.bitmapFont != null) {
                    _bitmapTextField.text = value;
                    requestLayout();
                    return value;
                }
            #end

            if (_font.ttfFontName != null) {
                _textField.htmlText = getHtmlTextForTextField();
                requestLayout();
            }
        }

        return value;
    }

    @:noCompletion
    private function get_editable():Bool {
        return _editable;
    }

    @:noCompletion
    private function set_editable(value:Bool):Bool {
        if (_editable != value) {
            _editable = value;
            reConfigure();
        }

        return value;
    }

    @:noCompletion
    private function get_displayAsPassword():Bool {
        return _displayAsPassword;
    }

    @:noCompletion
    private function set_displayAsPassword(value:Bool):Bool {
        if (_displayAsPassword != value) {
            _displayAsPassword = value;
            reConfigure();
        }

        return value;
    }
}
