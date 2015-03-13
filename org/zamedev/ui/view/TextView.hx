package org.zamedev.ui.view;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.errors.ArgumentError;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import org.zamedev.ui.Context;
import org.zamedev.ui.graphics.FontExt;
import org.zamedev.ui.graphics.TextAlignExt;
import org.zamedev.ui.internal.TextFieldExt;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.TypedValue;

using StringTools;

#if bitmapFont
    import bitmapFont.BitmapTextAlign;
    import bitmapFont.BitmapTextField;
#end

class TextView extends View {
    private var _font:FontExt;
    private var _textColor:Null<Int>;
    private var _textSize:Null<Float>;
    private var _textLeading:Null<Float>;
    private var _textAlign:TextAlignExt;
    private var _text:String;
    private var _htmlText:String;

    private var _textField:TextFieldExt;
    private var _textFormat:TextFormat;

    #if (!flash && !webgl && !dom)
        private var _cachedBitmap:Bitmap;
    #end

    #if bitmapFont
        private var _bitmapTextField:BitmapTextField;
    #end

    public var font(get, set):FontExt;
    public var textColor(get, set):Null<Int>;
    public var textSize(get, set):Null<Float>;
    public var textLeading(get, set):Null<Float>;
    public var textAlign(get, set):TextAlignExt;
    public var text(get, set):String;
    public var htmlText(never, set):String;

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

        _textField = null;
        _textFormat = null;

        #if (!flash && !webgl && !dom)
            _cachedBitmap = null;
        #end

        #if bitmapFont
            _bitmapTextField = null;
        #end
    }

    private function reConfigure():Void {
        if (_textField != null && _textField.parent != null) {
            _sprite.removeChild(_textField);
        }

        #if (!flash && !webgl && !dom)
            if (_cachedBitmap != null) {
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
                _bitmapTextField.lineSpacing = (_textLeading == null ? 0 : Std.int(_textLeading));
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
                _textField.selectable = false;

                // _textField.backgroundColor = 0x800000;
                // _textField.background = true;

                _textFormat = new TextFormat();

                #if (!flash && !webgl && !dom)
                    _cachedBitmap = new Bitmap();
                #end
            }

            #if (!flash && !webgl && !dom)
                _sprite.addChild(_cachedBitmap);
            #else
                _sprite.addChild(_textField);
            #end

            _textFormat.font = _font.ttfFontName;
            _textFormat.color = _textColor;
            _textFormat.size = _textSize;
            _textFormat.leading = #if flash (_textLeading == null ? null : _textLeading - 4.0) #else _textLeading #end;
            _textFormat.align = getAlignForTextField();

            _textField.defaultTextFormat = _textFormat;
            _textField.setTextFormat(_textFormat);

            if (_text != null) {
                _textField.text = _text;
            } else if (_htmlText != null) {
                _textField.htmlText = getHtmlTextForTextField();
            }
        }
    }

    private function getAlignForTextField():TextFormatAlign {
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

        return ~/"(@font\/[^"]+)"/g.map(_htmlText, function(re:EReg):String {
            return "\"" + _context.resourceManager.getFont(re.matched(1)) + "\"";
        });
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

    override public function inflate(name:String, value:TypedValue):Bool {
        if (super.inflate(name, value)) {
            return true;
        }

        switch (name) {
            case "textColor":
                textColor = value.resolveColor();
                return true;

            case "textSize":
                textSize = computeDimension(value.resolveDimension(), true);
                return true;

            case "textLeading":
                textLeading = computeDimension(value.resolveDimension(), true);
                return true;

            case "textAlign":
                textAlign = switch(value.resolveString().trim().toLowerCase()) {
                    case "center":
                        TextAlignExt.CENTER;

                    case "justify":
                        TextAlignExt.JUSTIFY;

                    case "right":
                        TextAlignExt.RIGHT;

                    case "left":
                        TextAlignExt.LEFT;

                    default:
                        throw new ArgumentError("Unsupported text align: " + value.resolveString());
                }

                return true;

            case "font":
                font = value.resolveFont();
                return true;

            case "text":
                text = value.resolveString();
                return true;

            case "htmlText":
                htmlText = value.resolveString();
                return true;
        }

        return false;
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
            switch (widthSpec) {
                case MeasureSpec.UNSPECIFIED:
                    _textField.width = 512;

                case MeasureSpec.EXACT(size) | MeasureSpec.AT_MOST(size):
                    _textField.width = size;
            }

            switch (heightSpec) {
                case MeasureSpec.UNSPECIFIED:
                    _textField.height = 512;

                case MeasureSpec.EXACT(size) | MeasureSpec.AT_MOST(size):
                    _textField.height = size;
            }

            switch (widthSpec) {
                case MeasureSpec.UNSPECIFIED | MeasureSpec.AT_MOST(_):
                    #if (native || mobile)
                        _width = _textField.textWidth * 1.1;
                    #elseif flash
                        _width = _textField.textWidth + 4;
                    #else
                        _width = _textField.textWidth;
                    #end

                    switch (widthSpec) {
                        case MeasureSpec.AT_MOST(size):
                            _width = Math.min(size, _width);

                        default:
                    }

                case MeasureSpec.EXACT(size):
                    _width = size;
            }

            _textField.width = _width;

            switch (heightSpec) {
                case MeasureSpec.UNSPECIFIED | MeasureSpec.AT_MOST(_):
                    _height = _textField.textHeight;

                    switch (heightSpec) {
                        case MeasureSpec.AT_MOST(size):
                            _height = Math.min(size, _height);

                        default:
                    }

                case MeasureSpec.EXACT(size):
                    _height = size;
            }

            #if flash
                _textField.height = _height + 4;
            #else
                _textField.height = _height;
            #end

            #if (!flash && !webgl && !dom)
                updateCache();
            #end
        }

        return true;
    }

    #if (!flash && !webgl && !dom)
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

                #if (!flash && !webgl && !dom)
                    updateCache();
                #end
            }
        }

        return value;
    }

    @:noCompletion
    private function get_textSize():Null<Float> {
        return _textSize;
    }

    @:noCompletion
    private function set_textSize(value:Null<Float>):Null<Float> {
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
    private function get_textLeading():Null<Float> {
        return _textLeading;
    }

    @:noCompletion
    private function set_textLeading(value:Null<Float>):Null<Float> {
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
                _textFormat.leading = #if flash (_textLeading == null ? null : _textLeading - 4.0) #else _textLeading #end;
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

                #if (!flash && !webgl && !dom)
                    updateCache();
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
}
