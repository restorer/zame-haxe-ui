package org.zamedev.ui.widget;

import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import org.zamedev.ui.Context;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.graphics.FontExt;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.Styleable;
import org.zamedev.ui.view.ImageView;
import org.zamedev.ui.view.Rect;
import org.zamedev.ui.view.TextView;
import org.zamedev.ui.view.ViewContainer;

class Button extends ViewContainer {
    private var backgroundView:ImageView;
    private var leftIconView:ImageView;
    private var rightIconView:ImageView;
    private var upIconView:ImageView;
    private var downIconView:ImageView;
    private var textView:TextView;
    private var hitTestView:Rect;

    private var listenersAdded:Bool;
    private var _disabled:Bool;

    public var background(get, set):Drawable;
    public var leftIcon(get, set):Drawable;
    public var rightIcon(get, set):Drawable;
    public var upIcon(get, set):Drawable;
    public var downIcon(get, set):Drawable;
    public var backgroundOffset(get, set):Point;
    public var backgroundOffsetX(get, set):Float;
    public var backgroundOffsetY(get, set):Float;
    public var leftIconOffset(get, set):Point;
    public var leftIconOffsetX(get, set):Float;
    public var leftIconOffsetY(get, set):Float;
    public var rightIconOffset(get, set):Point;
    public var rightIconOffsetX(get, set):Float;
    public var rightIconOffsetY(get, set):Float;
    public var upIconOffset(get, set):Point;
    public var upIconOffsetX(get, set):Float;
    public var upIconOffsetY(get, set):Float;
    public var downIconOffset(get, set):Point;
    public var downIconOffsetX(get, set):Float;
    public var downIconOffsetY(get, set):Float;
    public var textOffset(get, set):Point;
    public var textOffsetX(get, set):Float;
    public var textOffsetY(get, set):Float;
    public var textColor(get, set):Null<UInt>;
    public var textSize(get, set):Null<Float>;
    public var font(get, set):FontExt;
    public var text(get, set):String;
    public var leftIconMargin(default, set):Float;
    public var rightIconMargin(default, set):Float;
    public var upIconMargin(default, set):Float;
    public var downIconMargin(default, set):Float;
    public var disabled(get, set):Bool;
    public var leftIconAlpha(get, set):Float;
    public var rightIconAlpha(get, set):Float;
    public var upIconAlpha(get, set):Float;
    public var downIconAlpha(get, set):Float;

    @:keep
    public function new(context:Context) {
        super(context);

        _addChild(backgroundView = new ImageView(context));
        _addChild(leftIconView = new ImageView(context));
        _addChild(rightIconView = new ImageView(context));
        _addChild(upIconView = new ImageView(context));
        _addChild(downIconView = new ImageView(context));
        _addChild(textView = new TextView(context));
        _addChild(hitTestView = new Rect(context));

        listenersAdded = false;
        leftIconMargin = 0.0;
        rightIconMargin = 0.0;
        upIconMargin = 0.0;
        downIconMargin = 0.0;
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
    }

    override private function _inflate(attId:Styleable, value:Dynamic):Bool {
        if (super._inflate(attId, value)) {
            return true;
        }

        switch (attId) {
            case Styleable.background:
                background = cast value;
                return true;

            case Styleable.leftIcon:
                leftIcon = cast value;
                return true;

            case Styleable.rightIcon:
                rightIcon = cast value;
                return true;

            case Styleable.upIcon:
                upIcon = cast value;
                return true;

            case Styleable.downIcon:
                downIcon = cast value;
                return true;

            case Styleable.backgroundOffsetX:
                backgroundOffsetX = computeDimension(cast value, false);
                return true;

            case Styleable.backgroundOffsetY:
                backgroundOffsetY = computeDimension(cast value, true);
                return true;

            case Styleable.leftIconOffsetX:
                leftIconOffsetX = computeDimension(cast value, false);
                return true;

            case Styleable.leftIconOffsetY:
                leftIconOffsetY = computeDimension(cast value, true);
                return true;

            case Styleable.rightIconOffsetX:
                rightIconOffsetX = computeDimension(cast value, false);
                return true;

            case Styleable.rightIconOffsetY:
                rightIconOffsetY = computeDimension(cast value, true);
                return true;

            case Styleable.upIconOffsetX:
                upIconOffsetX = computeDimension(cast value, false);
                return true;

            case Styleable.upIconOffsetY:
                upIconOffsetY = computeDimension(cast value, true);
                return true;

            case Styleable.downIconOffsetX:
                downIconOffsetX = computeDimension(cast value, false);
                return true;

            case Styleable.downIconOffsetY:
                downIconOffsetY = computeDimension(cast value, true);
                return true;

            case Styleable.textOffsetX:
                textOffsetX = computeDimension(cast value, false);
                return true;

            case Styleable.textOffsetY:
                textOffsetY = computeDimension(cast value, true);
                return true;

            case Styleable.textColor:
                textColor = cast value;
                return true;

            case Styleable.textSize:
                textSize = computeDimension(cast value, true);
                return true;

            case Styleable.font:
                font = cast value;
                return true;

            case Styleable.text:
                text = cast value;
                return true;

            case Styleable.leftIconMargin:
                leftIconMargin = computeDimension(cast value, false);
                return true;

            case Styleable.rightIconMargin:
                rightIconMargin = computeDimension(cast value, false);
                return true;

            case Styleable.upIconMargin:
                upIconMargin = computeDimension(cast value, true);
                return true;

            case Styleable.downIconMargin:
                downIconMargin = computeDimension(cast value, true);
                return true;

            case Styleable.disabled:
                disabled = cast value;
                return true;

            case Styleable.leftIconAlpha:
                leftIconAlpha = cast value;
                return true;

            case Styleable.rightIconAlpha:
                rightIconAlpha = cast value;
                return true;

            case Styleable.upIconAlpha:
                upIconAlpha = cast value;
                return true;

            case Styleable.downIconAlpha:
                downIconAlpha = cast value;
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
        leftIconView.selfLayout(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED);
        rightIconView.selfLayout(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED);
        upIconView.selfLayout(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED);
        downIconView.selfLayout(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED);
        textView.selfLayout(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED);

        var leftIconWidth = (leftIconView.drawable == null ? 0 : leftIconView.width + leftIconMargin);
        var rightIconWidth = (rightIconView.drawable == null ? 0 : rightIconView.width + rightIconMargin);
        var upIconHeight = (upIconView.drawable == null ? 0 : upIconView.height + upIconMargin);
        var downIconHeight = (downIconView.drawable == null ? 0 : downIconView.height + downIconMargin);

        _width = Math.max(
            Math.max(
                Math.max(backgroundView.width, leftIconWidth + textView.width + rightIconWidth),
                upIconView.width
            ),
            downIconView.width
        );

        _height = Math.max(
            Math.max(
                Math.max(backgroundView.height, leftIconView.height),
                rightIconView.height
            ),
            upIconHeight + textView.height + downIconHeight
        );

        var textCx = (_width + leftIconWidth - rightIconWidth) / 2;
        var textCy = (_height + upIconHeight - downIconHeight) / 2;

        textView.cx = textCx;
        textView.cy = textCy;

        leftIconView.ex = textView.x - leftIconMargin;
        leftIconView.cy = textCy;

        rightIconView.x = textView.ex + rightIconMargin;
        rightIconView.cy = textCy;

        upIconView.cx = textCx;
        upIconView.ey = textView.y - upIconMargin;

        downIconView.cx = textCx;
        downIconView.y = textView.ey + downIconMargin;

        hitTestView.selfLayout(MeasureSpec.EXACT(_width), MeasureSpec.EXACT(_height));
        return true;
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
    private function get_upIcon():Drawable {
        return upIconView.drawable;
    }

    @:noCompletion
    private function set_upIcon(value:Drawable):Drawable {
        upIconView.drawable = value;
        return value;
    }

    @:noCompletion
    private function get_downIcon():Drawable {
        return downIconView.drawable;
    }

    @:noCompletion
    private function set_downIcon(value:Drawable):Drawable {
        downIconView.drawable = value;
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
    private function get_upIconOffset():Point {
        return upIconView.offset;
    }

    @:noCompletion
    private function set_upIconOffset(value:Point):Point {
        upIconView.offset = value;
        return value;
    }

    @:noCompletion
    private function get_upIconOffsetX():Float {
        return upIconView.offsetX;
    }

    @:noCompletion
    private function set_upIconOffsetX(value:Float):Float {
        upIconView.offsetX = value;
        return value;
    }

    @:noCompletion
    private function get_upIconOffsetY():Float {
        return upIconView.offsetY;
    }

    @:noCompletion
    private function set_upIconOffsetY(value:Float):Float {
        upIconView.offsetY = value;
        return value;
    }

    @:noCompletion
    private function get_downIconOffset():Point {
        return downIconView.offset;
    }

    @:noCompletion
    private function set_downIconOffset(value:Point):Point {
        downIconView.offset = value;
        return value;
    }

    @:noCompletion
    private function get_downIconOffsetX():Float {
        return downIconView.offsetX;
    }

    @:noCompletion
    private function set_downIconOffsetX(value:Float):Float {
        downIconView.offsetX = value;
        return value;
    }

    @:noCompletion
    private function get_downIconOffsetY():Float {
        return downIconView.offsetY;
    }

    @:noCompletion
    private function set_downIconOffsetY(value:Float):Float {
        downIconView.offsetY = value;
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
    private function get_font():FontExt {
        return textView.font;
    }

    @:noCompletion
    private function set_font(value:FontExt):FontExt {
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
    private function set_upIconMargin(value:Float):Float {
        upIconMargin = value;
        requestLayout();
        return value;
    }

    @:noCompletion
    private function set_downIconMargin(value:Float):Float {
        downIconMargin = value;
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

    @:noCompletion
    private function get_upIconAlpha():Float {
        return upIconView.alpha;
    }

    @:noCompletion
    private function set_upIconAlpha(value:Float):Float {
        upIconView.alpha = value;
        return value;
    }

    @:noCompletion
    private function get_downIconAlpha():Float {
        return downIconView.alpha;
    }

    @:noCompletion
    private function set_downIconAlpha(value:Float):Float {
        downIconView.alpha = value;
        return value;
    }
}
