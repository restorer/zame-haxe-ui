package org.zamedev.ui.internal;

import org.zamedev.ui.graphics.ScaleMode;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;

class ApplicationStage extends Sprite {
    private var scaleMode:ScaleMode;
    private var appStageWidth:Float;
    private var appStageHeight:Float;
    private var maskShape:Shape;
    private var listenerAdded:Bool;

    public var clippingEnabled(default, set):Bool;
    public var widthWeightSum(default, set):Float;
    public var heightWeightSum(default, set):Float;

    public function new() {
        super();

        scaleMode = ScaleMode.CENTER_INSIDE;
        appStageWidth = 0.0;
        appStageHeight = 0.0;
        maskShape = new Shape();
        listenerAdded = false;
        widthWeightSum = 1.0;
        heightWeightSum = 1.0;

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);

        if (stage != null) {
            listenerAdded = true;
            stage.addEventListener(Event.RESIZE, onStageResize);
        }
    }

    public function setStageSize(width:Float, height:Float, scaleMode:ScaleMode = null):Void {
        if (scaleMode == null) {
            scaleMode = ScaleMode.CENTER_INSIDE;
        }

        if (appStageWidth != width || appStageHeight != height || this.scaleMode != scaleMode) {
            appStageWidth = width;
            appStageHeight = height;
            this.scaleMode = scaleMode;

            if (stage != null) {
                onStageResize(null);
            }
        }
    }

    public function setWeightSums(widthWeightSum:Float, heightWeightSum:Float) {
        this.widthWeightSum = widthWeightSum;
        this.heightWeightSum = heightWeightSum;
    }

    @:noCompletion
    private function set_widthWeightSum(value:Float):Float {
        widthWeightSum = Math.max(1.0, value);
        return value;
    }

    @:noCompletion
    private function set_heightWeightSum(value:Float):Float {
        heightWeightSum = Math.max(1.0, value);
        return value;
    }

    @:noCompletion
    private function set_clippingEnabled(value:Bool):Bool {
        if (clippingEnabled != value) {
            if (!value) {
                mask = null;
                removeChild(maskShape);
            } else {
                addChild(maskShape);
                mask = maskShape;
            }

            clippingEnabled = value;
            updateMask();
        }

        return value;
    }

    #if flash
        @:noCompletion
        @:getter(width)
        private function get_width():Float {
            return appStageWidth;
        }

        @:noCompletion
        @:setter(width)
        private function set_width(value:Float):Void {
            if (appStageWidth != value) {
                appStageWidth = value;
                onStageResize(null);
            }
        }

        @:noCompletion
        @:getter(height)
        private function get_height():Float {
            return appStageHeight;
        }

        @:noCompletion
        @:setter(height)
        private function set_height(value:Float):Void {
            if (appStageHeight != value) {
                appStageHeight = value;
                onStageResize(null);
            }
        }
    #else
        @:noCompletion
        override private function get_width():Float {
            return appStageWidth;
        }

        @:noCompletion
        override private function set_width(value:Float):Float {
            if (appStageWidth != value) {
                appStageWidth = value;
                onStageResize(null);
            }

            return value;
        }

        @:noCompletion
        override private function get_height():Float {
            return appStageHeight;
        }

        @:noCompletion
        override private function set_height(value:Float):Float {
            if (appStageHeight != value) {
                appStageHeight = value;
                onStageResize(null);
            }

            return value;
        }
    #end

    private function updateMask():Void {
        maskShape.graphics.clear();

        if (clippingEnabled && appStageWidth > 0 && appStageHeight > 0) {
            maskShape.graphics.beginFill(0x000000);
            maskShape.graphics.drawRect(0, 0, appStageWidth, appStageHeight);
            maskShape.graphics.endFill();
        }
    }

    private function onAddedToStage(_):Void {
        if (!listenerAdded) {
            listenerAdded = true;
            stage.addEventListener(Event.RESIZE, onStageResize);
        }
    }

    private function onRemovedFromStage(_):Void {
        if (listenerAdded) {
            listenerAdded = false;
            stage.removeEventListener(Event.RESIZE, onStageResize);
        }
    }

    private function onStageResize(_):Void {
        if (stage.stageWidth < 1 || stage.stageHeight < 1 || appStageWidth < 1 || appStageHeight < 1) {
            x = 0;
            y = 0;
            scaleX = 1.0;
            scaleY = 1.0;
        } else {
            switch (scaleMode) {
                case CENTER_INSIDE | CENTER_CROP: {
                    var desiredRatio = appStageWidth / appStageHeight;
                    var stageRatio = stage.stageWidth / stage.stageHeight;
                    var scale:Float;

                    if ((scaleMode == CENTER_INSIDE && stageRatio < desiredRatio)
                        || (scaleMode == CENTER_CROP && stageRatio > desiredRatio)
                    ) {
                        scale = stage.stageWidth / appStageWidth;
                        y = Math.round((stage.stageHeight - appStageHeight * scale) / 2);
                        x = 0;
                    } else {
                        scale = stage.stageHeight / appStageHeight;
                        x = Math.round((stage.stageWidth - appStageWidth * scale) / 2);
                        y = 0;
                    }

                    scaleX = scale;
                    scaleY = scale;
                }

                case FIT_XY: {
                    x = 0;
                    y = 0;
                    scaleX = stage.stageWidth / appStageWidth;
                    scaleY = stage.stageHeight / appStageHeight;
                }
            }
        }

        updateMask();
        dispatchEvent(new Event(Event.RESIZE));
    }
}
