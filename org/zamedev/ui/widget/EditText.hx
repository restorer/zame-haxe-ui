package org.zamedev.ui.widget;

import openfl.events.FocusEvent;
import openfl.geom.Point;
import org.zamedev.ui.Context;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.graphics.FontExt;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.Styleable;
import org.zamedev.ui.view.ImageView;
import org.zamedev.ui.view.TextView;
import org.zamedev.ui.view.ViewContainer;
import org.zamedev.ui.view.ViewVisibility;

using StringTools;

class EditText extends ViewContainer {
    private var _paddingLeft:Float;
    private var _paddingRight:Float;
    private var _disabled:Bool;

    private var backgroundView:ImageView;
    private var placeholderTextView:TextView;
    private var editableTextView:TextView;
    private var focused:Bool;

    public var background(get, set):Drawable;
    public var backgroundOffset(get, set):Point;
    public var backgroundOffsetX(get, set):Float;
    public var backgroundOffsetY(get, set):Float;
    public var textOffset(get, set):Point;
    public var textOffsetX(get, set):Float;
    public var textOffsetY(get, set):Float;
    public var textColor(get, set):Null<Int>;
    public var placeholderTextColor(get, set):Null<Int>;
    public var textSize(get, set):Null<Int>;
    public var font(get, set):FontExt;
    public var text(get, set):String;
    public var placeholderText(get, set):String;
    public var paddingLeft(get, set):Float;
    public var paddingRight(get, set):Float;
    public var paddingHorizontal(never, set):Float;
    public var padding(never, set):Float;
    public var disabled(get, set):Bool;

    @:keep
    public function new(context:Context) {
        super(context);

        _addChild(backgroundView = new ImageView(context));
        _addChild(placeholderTextView = new TextView(context));
        _addChild(editableTextView = new TextView(context));

        _paddingLeft = 0.0;
        _paddingRight = 0.0;
        _disabled = false;

        focused = false;

        editableTextView.editable = true;
        editableTextView.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
        editableTextView.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
    }

    override private function _inflate(attId:Styleable, value:Dynamic):Bool {
        if (super._inflate(attId, value)) {
            return true;
        }

        switch (attId) {
            case Styleable.background:
                background = cast value;
                return true;

            case Styleable.backgroundOffsetX:
                backgroundOffsetX = computeDimension(cast value, false);
                return true;

            case Styleable.backgroundOffsetY:
                backgroundOffsetY = computeDimension(cast value, true);
                return true;

            case Styleable.textColor:
                textColor = cast value;
                return true;

            case Styleable.placeholderTextColor:
                placeholderTextColor = cast value;
                return true;

            case Styleable.textSize:
                textSize = Std.int(computeDimension(cast value, true));
                return true;

            case Styleable.font:
                font = cast value;
                return true;

            case Styleable.text:
                text = cast value;
                return true;

            case Styleable.placeholderText:
                placeholderText = cast value;
                return true;

            case Styleable.paddingLeft:
                paddingLeft = computeDimension(cast value, false);
                return true;

            case Styleable.paddingRight:
                paddingRight = computeDimension(cast value, false);
                return true;

            case Styleable.paddingHorizontal:
                paddingHorizontal = computeDimension(cast value, false);
                return true;

            case Styleable.padding:
                padding = computeDimension(cast value, false);
                return true;

            case Styleable.disabled:
                disabled = cast value;
                return true;

            default:
                return false;
        }
    }

    override private function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
        if (super.measureAndLayout(widthSpec, heightSpec)) {
            return true;
        }

        backgroundView.selfLayout(widthSpec, heightSpec);
        placeholderTextView.selfLayout(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED);

        _width = Math.max(backgroundView.width, placeholderTextView.width);
        _height = Math.max(backgroundView.height, placeholderTextView.height);

        editableTextView.selfLayout(
            MeasureSpec.EXACT(_width - _paddingLeft - _paddingRight),
            MeasureSpec.EXACT(placeholderTextView.height)
        );

        var textX = _paddingLeft;
        var textCy = _height / 2.0;

        editableTextView.x = textX;
        editableTextView.cy = textCy;

        placeholderTextView.x = textX;
        placeholderTextView.cy = textCy;

        reConfigure();
        return true;
    }

    private function reConfigure():Void {
        placeholderTextView.visibility = ((focused || (editableTextView.text != null && editableTextView.text != ""))
            ? ViewVisibility.INVISIBLE
            : ViewVisibility.VISIBLE
        );
    }

    private function onFocusIn(_):Void {
        if (!_disabled) {
            focused = true;
            reConfigure();
        }
    }

    private function onFocusOut(_):Void {
        if (!_disabled) {
            focused = false;
            reConfigure();
        }
    }

    @:noCompletion
    private function get_background():Drawable {
        return backgroundView.drawable;
    }

    @:noCompletion
    private function set_background(value:Drawable):Drawable {
        backgroundView.drawable = value;
        return value;
    }

    @:noCompletion
    private function get_backgroundOffset():Point {
        return backgroundView.offset;
    }

    @:noCompletion
    private function set_backgroundOffset(value:Point):Point {
        backgroundView.offset = value;
        return value;
    }

    @:noCompletion
    private function get_backgroundOffsetX():Float {
        return backgroundView.offsetX;
    }

    @:noCompletion
    private function set_backgroundOffsetX(value:Float):Float {
        backgroundView.offsetX = value;
        return value;
    }

    @:noCompletion
    private function get_backgroundOffsetY():Float {
        return backgroundView.offsetY;
    }

    @:noCompletion
    private function set_backgroundOffsetY(value:Float):Float {
        backgroundView.offsetY = value;
        return value;
    }

    @:noCompletion
    private function get_textOffset():Point {
        return editableTextView.offset;
    }

    @:noCompletion
    private function set_textOffset(value:Point):Point {
        editableTextView.offset = value;
        placeholderTextView.offset = value;
        return value;
    }

    @:noCompletion
    private function get_textOffsetX():Float {
        return editableTextView.offsetX;
    }

    @:noCompletion
    private function set_textOffsetX(value:Float):Float {
        editableTextView.offsetX = value;
        placeholderTextView.offsetX = value;
        return value;
    }

    @:noCompletion
    private function get_textOffsetY():Float {
        return editableTextView.offsetY;
    }

    @:noCompletion
    private function set_textOffsetY(value:Float):Float {
        editableTextView.offsetY = value;
        placeholderTextView.offsetY = value;
        return value;
    }

    @:noCompletion
    private function get_textColor():Null<Int> {
        return editableTextView.textColor;
    }

    @:noCompletion
    private function set_textColor(value:Null<UInt>):Null<Int> {
        editableTextView.textColor = value;
        return value;
    }

    @:noCompletion
    private function get_placeholderTextColor():Null<Int> {
        return placeholderTextView.textColor;
    }

    @:noCompletion
    private function set_placeholderTextColor(value:Null<UInt>):Null<Int> {
        placeholderTextView.textColor = value;
        return value;
    }

    @:noCompletion
    private function get_textSize():Null<Int> {
        return editableTextView.textSize;
    }

    @:noCompletion
    private function set_textSize(value:Null<Int>):Null<Int> {
        editableTextView.textSize = value;
        placeholderTextView.textSize = value;
        return value;
    }

    @:noCompletion
    private function get_font():FontExt {
        return editableTextView.font;
    }

    @:noCompletion
    private function set_font(value:FontExt):FontExt {
        editableTextView.font = value;
        placeholderTextView.font = value;
        return value;
    }

    @:noCompletion
    private function get_text():String {
        return editableTextView.text;
    }

    @:noCompletion
    private function set_text(value:String):String {
        editableTextView.text = value;
        reConfigure();
        return value;
    }

    @:noCompletion
    private function get_placeholderText():String {
        return placeholderTextView.text;
    }

    @:noCompletion
    private function set_placeholderText(value:String):String {
        placeholderTextView.text = value;
        return value;
    }

    @:noCompletion
    private function get_paddingLeft():Float {
        return _paddingLeft;
    }

    @:noCompletion
    private function set_paddingLeft(value:Float):Float {
        _paddingLeft = value;
        requestLayout();
        return value;
    }

    @:noCompletion
    private function get_paddingRight():Float {
        return _paddingRight;
    }

    @:noCompletion
    private function set_paddingRight(value:Float):Float {
        _paddingRight = value;
        requestLayout();
        return value;
    }

    @:noCompletion
    private function set_paddingHorizontal(value:Float):Float {
        _paddingLeft = value;
        _paddingRight = value;
        requestLayout();
        return value;
    }

    @:noCompletion
    private function set_padding(value:Float):Float {
        _paddingLeft = value;
        _paddingRight = value;
        requestLayout();
        return value;
    }

    @:noCompletion
    private function get_disabled():Bool {
        return _disabled;
    }

    @:noCompletion
    private function set_disabled(value:Bool):Bool {
        if (_disabled != value) {
            _disabled = value;
            updateState("disabled", _disabled);

            if (_disabled && focused) {
                focused = false;
                reConfigure();
            }

            editableTextView.editable = !_disabled;
        }

        return value;
    }
}
