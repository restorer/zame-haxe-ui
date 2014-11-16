package org.zamedev.ui.widget;

import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.res.TypedValue;
import org.zamedev.ui.view.ImageView;
import org.zamedev.ui.view.TextView;
import org.zamedev.ui.view.View;

class Button extends View {
    private static inline var CUSTOM_CLICK:String = "customClick";

    private var backgroundView:ImageView;
    private var iconView:ImageView;
    private var textView:TextView;
    private var listenersAttached:Bool;

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
    public var iconMargin(default, set):Float;
    public var enabled:Bool;

    public function new() {
        super();

        addChild(backgroundView = new ImageView());
        addChild(iconView = new ImageView());
        addChild(textView = new TextView());

        listenersAttached = false;
        iconMargin = 16;
        enabled = true;

        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
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

            case "iconMargin":
                iconMargin = value.resolveFloat();
                return true;

        }

        return false;
    }

    override public function onMeasure(child:View = null):Void {
        if (backgroundView.drawable == null) {
            if (iconView.drawable == null) {
                iconView.x = 0;
                iconView.y = 0;
                textView.x = 0;
                textView.y = 0;
            } else {
                var cy = Math.max(iconView.height, textView.height) / 2;

                iconView.x = 0;
                iconView.cy = cy;
                textView.x = iconView.width + iconMargin;
                textView.cy = cy;
            }
        } else {
            var cx = backgroundView.cx;
            var cy = backgroundView.cy;

            if (iconView.drawable == null) {
                iconView.x = 0;
                iconView.y = 0;
                textView.cx = cx;
                textView.cy = cy;
            } else {
                cx += (iconMargin + iconView.width) / 2;

                iconView.ex = cx - (textView.width / 2) - iconMargin;
                iconView.cy = cy;
                textView.cx = cx;
                textView.cy = cy;
            }
        }
    }

    override public function addEventListener(
        type:String,
        listener:Dynamic->Void,
        useCapture:Bool = false,
        priority:Int = 0,
        useWeakReference:Bool = false
    ):Void {
        if (type == MouseEvent.CLICK) {
            type = CUSTOM_CLICK;
        }

        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    override public function removeEventListener(type:String, listener:Dynamic->Void, capture:Bool = false):Void {
        if (type == MouseEvent.CLICK) {
            type = CUSTOM_CLICK;
        }

        super.removeEventListener(type, listener, capture);
    }

    @:noCompletion private function onMouseDown(e:Event):Void {
        if (!listenersAttached && enabled) {
            listenersAttached = true;
            updateState("pressed", true);

            if (stage != null) {
                stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
                stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
            }
        }
    }

    @:noCompletion private function onMouseUp(e:Event):Void {
        if (listenersAttached) {
            dispatchEvent(new Event(CUSTOM_CLICK));
        }
    }

    @:noCompletion private function onMouseMove(e:Event):Void {
        if (listenersAttached) {
            e.stopPropagation();
            updateState("pressed", true);
        }
    }

    @:noCompletion private function onRemovedFromStage(_):Void {
        if (listenersAttached) {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
        }
    }

    @:noCompletion private function onStageMouseMove(_):Void {
        updateState("pressed", false);
    }

    @:noCompletion private function onStageMouseUp(_):Void {
        if (listenersAttached) {
            listenersAttached = false;
            updateState("pressed", false);

            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
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
    private function set_iconMargin(value:Float):Float {
        iconMargin = value;
        return value;
    }
}
