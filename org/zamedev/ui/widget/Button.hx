package org.zamedev.ui.widget;

import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.TypedValue;
import org.zamedev.ui.view.ImageView;
import org.zamedev.ui.view.TextView;
import org.zamedev.ui.view.ViewGroup;

class Button extends ViewGroup {
    private var backgroundView:ImageView;
    private var iconView:ImageView;
    private var textView:TextView;
    private var listenersAdded:Bool;

    public var background(get, set):Drawable;
    public var icon(get, set):Drawable;
    public var backgroundOffset(get, set):Point;
    public var backgroundOffsetX(get, set):Float;
    public var backgroundOffsetY(get, set):Float;
    public var iconOffset(get, set):Point;
    public var iconOffsetX(get, set):Float;
    public var iconOffsetY(get, set):Float;
    public var textOffset(get, set):Point;
    public var textOffsetX(get, set):Float;
    public var textOffsetY(get, set):Float;
    public var textColor(get, set):Null<UInt>;
    public var textSize(get, set):Null<Float>;
    public var font(get, set):String;
    public var text(get, set):String;
    public var iconMarginRight(default, set):Float;
    public var enabled:Bool;

    public function new() {
        super();

        addChild(backgroundView = new ImageView());
        addChild(iconView = new ImageView());
        addChild(textView = new TextView());

        listenersAdded = false;
        iconMarginRight = 16;
        enabled = true;

        sprite.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        sprite.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        sprite.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        sprite.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
    }

    override public function inflate(name:String, value:TypedValue):Bool {
        if (super.inflate(name, value)) {
            return true;
        }

        switch (name) {
            case "background":
                background = value.resolveDrawable();
                return true;

            case "icon":
                icon = value.resolveDrawable();
                return true;

            case "backgroundOffsetX":
                backgroundOffset.x = value.resolveFloat();
                return true;

            case "backgroundOffsetY":
                backgroundOffsetY = value.resolveFloat();
                return true;

            case "iconOffsetX":
                backgroundOffset.x = value.resolveFloat();
                return true;

            case "iconOffsetY":
                backgroundOffsetY = value.resolveFloat();
                return true;

            case "textOffsetX":
                textOffsetX = value.resolveFloat();
                return true;

            case "textOffsetY":
                textOffsetY = value.resolveFloat();
                return true;

            case "textColor":
                textColor = value.resolveColor();
                return true;

            case "textSize":
                textSize = value.resolveFloat();
                return true;

            case "font":
                font = value.resolveFont();
                return true;

            case "text":
                text = value.resolveString();
                return true;

            case "iconMarginRight":
                iconMarginRight = value.resolveFloat();
                return true;

        }

        return false;
    }

    override public function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
        if (super.measureAndLayout(widthSpec, heightSpec)) {
            return true;
        }

        backgroundView.measureAndLayout(widthSpec, heightSpec);
        iconView.measureAndLayout(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED);
        textView.measureAndLayout(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED);

        var iconWidth = iconView.width = (iconView.drawable == null ? 0 : iconMarginRight);

        _width = Math.max(backgroundView.width, iconWidth + textView.width);
        _height = Math.max(Math.max(backgroundView.height, iconView.height), textView.height);

        if (iconView.drawable == null) {
            iconView.x = 0;
            textView.cx = _width / 2;
        } else {
            var pos = (_width + iconMarginRight + iconView.width) / 2;

            iconView.ex = pos - (textView.width / 2) - iconMarginRight;
            textView.cx = pos;
        }

        iconView.cy = _height / 2;
        textView.cy = _height / 2;

        return true;
    }

    @:noCompletion
    private function onMouseDown(e:Event):Void {
        if (!listenersAdded && enabled) {
            listenersAdded = true;
            updateState("pressed", true);

            if (sprite.stage != null) {
                sprite.stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
                sprite.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
            }
        }
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
            sprite.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
            sprite.stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
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

            sprite.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
            sprite.stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
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
    private function get_icon():Drawable {
        return iconView.drawable;
    }

    @:noCompletion
    private function set_icon(value:Drawable):Drawable {
        iconView.drawable = value;
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
    private function get_iconOffset():Point {
        return iconView.offset;
    }

    @:noCompletion
    private function set_iconOffset(value:Point):Point {
        iconView.offset = value;
        return value;
    }

    @:noCompletion
    private function get_iconOffsetX():Float {
        return iconView.offsetX;
    }

    @:noCompletion
    private function set_iconOffsetX(value:Float):Float {
        iconView.offsetX = value;
        return value;
    }

    @:noCompletion
    private function get_iconOffsetY():Float {
        return iconView.offsetY;
    }

    @:noCompletion
    private function set_iconOffsetY(value:Float):Float {
        iconView.offsetY = value;
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
    private function set_iconMarginRight(value:Float):Float {
        iconMarginRight = value;
        return value;
    }
}
