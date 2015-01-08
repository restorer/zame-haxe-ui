package org.zamedev.ui.widget;

import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import org.zamedev.ui.Context;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.TypedValue;
import org.zamedev.ui.view.ImageView;
import org.zamedev.ui.view.Rect;
import org.zamedev.ui.view.TextView;
import org.zamedev.ui.view.View;
import org.zamedev.ui.view.ViewContainer;

class Button extends ViewContainer {
    private var backgroundView:ImageView;
    private var leftIconView:ImageView;
    private var rightIconView:ImageView;
    private var textView:TextView;
    private var hitTestView:Rect;

    private var listenersAdded:Bool;
    private var _disabled:Bool;

    public var background(get, set):Drawable;
    public var leftIcon(get, set):Drawable;
    public var rightIcon(get, set):Drawable;
    public var backgroundOffset(get, set):Point;
    public var backgroundOffsetX(get, set):Float;
    public var backgroundOffsetY(get, set):Float;
    public var leftIconOffset(get, set):Point;
    public var leftIconOffsetX(get, set):Float;
    public var leftIconOffsetY(get, set):Float;
    public var rightIconOffset(get, set):Point;
    public var rightIconOffsetX(get, set):Float;
    public var rightIconOffsetY(get, set):Float;
    public var textOffset(get, set):Point;
    public var textOffsetX(get, set):Float;
    public var textOffsetY(get, set):Float;
    public var textColor(get, set):Null<UInt>;
    public var textSize(get, set):Null<Float>;
    public var font(get, set):String;
    public var text(get, set):String;
    public var leftIconMargin(default, set):Float;
    public var rightIconMargin(default, set):Float;
    public var disabled(get, set):Bool;
    public var leftIconAlpha(get, set):Float;
    public var rightIconAlpha(get, set):Float;

    @:keep
    public function new(context:Context) {
        super(context);

        _addChild(backgroundView = new ImageView(context));
        _addChild(leftIconView = new ImageView(context));
        _addChild(rightIconView = new ImageView(context));
        _addChild(textView = new TextView(context));
        _addChild(hitTestView = new Rect(context));

        listenersAdded = false;
        leftIconMargin = 0.0;
        rightIconMargin = 0.0;
        _disabled = false;

        #if flash
            _sprite.buttonMode = true;
        #elseif dom
            hitTestView.buttonMode = true;
        #end

        hitTestView.alpha = 0.0;

        _sprite.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        _sprite.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        _sprite.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        _sprite.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);

        addEventListener(Event.ADDED_TO_STAGE, onAddedToApplicationStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromApplicationStage);
    }

    override public function inflate(name:String, value:TypedValue):Bool {
        if (super.inflate(name, value)) {
            return true;
        }

        switch (name) {
            case "background":
                background = value.resolveDrawable();
                return true;

            case "leftIcon":
                leftIcon = value.resolveDrawable();
                return true;

            case "rightIcon":
                rightIcon = value.resolveDrawable();
                return true;

            case "backgroundOffsetX":
                backgroundOffsetX = computeDimension(value.resolveDimension(), false);
                return true;

            case "backgroundOffsetY":
                backgroundOffsetY = computeDimension(value.resolveDimension(), true);
                return true;

            case "leftIconOffsetX":
                leftIconOffsetX = computeDimension(value.resolveDimension(), false);
                return true;

            case "leftIconOffsetY":
                leftIconOffsetY = computeDimension(value.resolveDimension(), true);
                return true;

            case "rightIconOffsetX":
                rightIconOffsetX = computeDimension(value.resolveDimension(), false);
                return true;

            case "rightIconOffsetY":
                rightIconOffsetY = computeDimension(value.resolveDimension(), true);
                return true;

            case "textOffsetX":
                textOffsetX = computeDimension(value.resolveDimension(), false);
                return true;

            case "textOffsetY":
                textOffsetY = computeDimension(value.resolveDimension(), true);
                return true;

            case "textColor":
                textColor = value.resolveColor();
                return true;

            case "textSize":
                textSize = computeDimension(value.resolveDimension(), true);
                return true;

            case "font":
                font = value.resolveFont();
                return true;

            case "text":
                text = value.resolveString();
                return true;

            case "leftIconMargin":
                leftIconMargin = computeDimension(value.resolveDimension(), false);
                return true;

            case "rightIconMargin":
                rightIconMargin = computeDimension(value.resolveDimension(), false);
                return true;

            case "disabled":
                disabled = value.resolveBool();
                return true;

            case "leftIconAlpha":
                leftIconAlpha = value.resolveFloat();
                return true;

            case "rightIconAlpha":
                rightIconAlpha = value.resolveFloat();
                return true;
        }

        return false;
    }

    override private function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
        if (super.measureAndLayout(widthSpec, heightSpec)) {
            return true;
        }

        backgroundView.selfLayout(widthSpec, heightSpec);
        leftIconView.selfLayout(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED);
        rightIconView.selfLayout(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED);
        textView.selfLayout(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED);

        var leftIconWidth = (leftIconView.drawable == null ? 0 : leftIconView.width + leftIconMargin);
        var rightIconWidth = (rightIconView.drawable == null ? 0 : rightIconView.width + rightIconMargin);

        _width = Math.max(backgroundView.width, leftIconWidth + textView.width + rightIconWidth);
        _height = Math.max(Math.max(Math.max(backgroundView.height, leftIconView.height), rightIconView.height), textView.height);

        textView.cx = (_width + leftIconWidth - rightIconWidth) / 2;
        textView.cy = _height / 2;

        leftIconView.ex = textView.x - leftIconMargin;
        leftIconView.cy = _height / 2;

        rightIconView.x = textView.ex + rightIconMargin;
        rightIconView.cy = _height / 2;

        hitTestView.selfLayout(MeasureSpec.EXACT(_width), MeasureSpec.EXACT(_height));
        return true;
    }

    private function onAddedToApplicationStage(e:Event):Void {
        backgroundView.dispatchEvent(e);
        leftIconView.dispatchEvent(e);
        rightIconView.dispatchEvent(e);
        textView.dispatchEvent(e);
        hitTestView.dispatchEvent(e);
    }

    private function onRemovedFromApplicationStage(e:Event):Void {
        backgroundView.dispatchEvent(e);
        leftIconView.dispatchEvent(e);
        rightIconView.dispatchEvent(e);
        textView.dispatchEvent(e);
        hitTestView.dispatchEvent(e);
    }

    @:noCompletion
    private function onMouseDown(e:Event):Void {
        if (_disabled) {
            return;
        }

        if (!listenersAdded) {
            listenersAdded = true;
            updateState("pressed", true);

            if (_sprite.stage != null) {
                _sprite.stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
                _sprite.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
            }
        }

        dispatchEvent(new Event(MouseEvent.MOUSE_DOWN));
    }

    @:noCompletion
    private function onMouseUp(e:Event):Void {
        if (listenersAdded) {
            dispatchEvent(new Event(MouseEvent.CLICK));
        }
    }

    @:noCompletion
    private function onMouseMove(e:Event):Void {
        if (listenersAdded) {
            e.stopPropagation();
            updateState("pressed", true);
        }
    }

    @:noCompletion
    private function onRemovedFromStage(_):Void {
        if (listenersAdded) {
            _sprite.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
            _sprite.stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
        }
    }

    @:noCompletion
    private function onStageMouseMove(_):Void {
        updateState("pressed", false);
    }

    @:noCompletion
    private function onStageMouseUp(_):Void {
        if (listenersAdded) {
            listenersAdded = false;
            updateState("pressed", false);

            _sprite.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
            _sprite.stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
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
    private function get_leftIcon():Drawable {
        return leftIconView.drawable;
    }

    @:noCompletion
    private function set_leftIcon(value:Drawable):Drawable {
        leftIconView.drawable = value;
        return value;
    }

    @:noCompletion
    private function get_rightIcon():Drawable {
        return rightIconView.drawable;
    }

    @:noCompletion
    private function set_rightIcon(value:Drawable):Drawable {
        rightIconView.drawable = value;
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
    private function get_leftIconOffset():Point {
        return leftIconView.offset;
    }

    @:noCompletion
    private function set_leftIconOffset(value:Point):Point {
        leftIconView.offset = value;
        return value;
    }

    @:noCompletion
    private function get_leftIconOffsetX():Float {
        return leftIconView.offsetX;
    }

    @:noCompletion
    private function set_leftIconOffsetX(value:Float):Float {
        leftIconView.offsetX = value;
        return value;
    }

    @:noCompletion
    private function get_leftIconOffsetY():Float {
        return leftIconView.offsetY;
    }

    @:noCompletion
    private function set_leftIconOffsetY(value:Float):Float {
        leftIconView.offsetY = value;
        return value;
    }

    @:noCompletion
    private function get_rightIconOffset():Point {
        return rightIconView.offset;
    }

    @:noCompletion
    private function set_rightIconOffset(value:Point):Point {
        rightIconView.offset = value;
        return value;
    }

    @:noCompletion
    private function get_rightIconOffsetX():Float {
        return rightIconView.offsetX;
    }

    @:noCompletion
    private function set_rightIconOffsetX(value:Float):Float {
        rightIconView.offsetX = value;
        return value;
    }

    @:noCompletion
    private function get_rightIconOffsetY():Float {
        return rightIconView.offsetY;
    }

    @:noCompletion
    private function set_rightIconOffsetY(value:Float):Float {
        rightIconView.offsetY = value;
        return value;
    }

    @:noCompletion
    private function get_textOffset():Point {
        return textView.offset;
    }

    @:noCompletion
    private function set_textOffset(value:Point):Point {
        textView.offset = value;
        return value;
    }

    @:noCompletion
    private function get_textOffsetX():Float {
        return textView.offsetX;
    }

    @:noCompletion
    private function set_textOffsetX(value:Float):Float {
        textView.offsetX = value;
        return value;
    }

    @:noCompletion
    private function get_textOffsetY():Float {
        return textView.offsetY;
    }

    @:noCompletion
    private function set_textOffsetY(value:Float):Float {
        textView.offsetY = value;
        return value;
    }

    @:noCompletion
    private function get_textColor():Null<UInt> {
        return textView.textColor;
    }

    @:noCompletion
    private function set_textColor(value:Null<UInt>):Null<UInt> {
        textView.textColor = value;
        return value;
    }

    @:noCompletion
    private function get_textSize():Null<Float> {
        return textView.textSize;
    }

    @:noCompletion
    private function set_textSize(value:Null<Float>):Null<Float> {
        textView.textSize = value;
        return value;
    }

    @:noCompletion
    private function get_font():String {
        return textView.font;
    }

    @:noCompletion
    private function set_font(value:String):String {
        textView.font = value;
        return value;
    }

    @:noCompletion
    private function get_text():String {
        return textView.text;
    }

    @:noCompletion
    private function set_text(value:String):String {
        textView.text = value;
        return value;
    }

    @:noCompletion
    private function set_leftIconMargin(value:Float):Float {
        leftIconMargin = value;
        requestLayout();
        return value;
    }

    @:noCompletion
    private function set_rightIconMargin(value:Float):Float {
        rightIconMargin = value;
        requestLayout();
        return value;
    }

    @:noCompletion
    private function get_disabled():Bool {
        return _disabled;
    }

    @:noCompletion
    private function set_disabled(value:Bool):Bool {
        _disabled = value;
        updateState("disabled", value);
        return value;
    }

    @:noCompletion
    private function get_leftIconAlpha():Float {
        return leftIconView.alpha;
    }

    @:noCompletion
    private function set_leftIconAlpha(value:Float):Float {
        leftIconView.alpha = value;
        return value;
    }

    @:noCompletion
    private function get_rightIconAlpha():Float {
        return rightIconView.alpha;
    }

    @:noCompletion
    private function set_rightIconAlpha(value:Float):Float {
        rightIconView.alpha = value;
        return value;
    }
}
