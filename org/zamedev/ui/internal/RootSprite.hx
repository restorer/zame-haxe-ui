package org.zamedev.ui.internal;

import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;

class RootSprite extends Sprite {
    private var sceneWidth:Float;
    private var sceneHeight:Float;
    private var maskShape:Shape;
    private var listenerAdded:Bool;

    public var clippingEnabled(default, set):Bool;

    public function new() {
        super();

        sceneWidth = 0.0;
        sceneHeight = 0.0;
        maskShape = new Shape();
        listenerAdded = false;

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);

        if (stage != null) {
            listenerAdded = true;
            stage.addEventListener(Event.RESIZE, onStageResize);
        }
    }

    public function setSceneSize(width:Float, height:Float):Void {
        if (sceneWidth != width || sceneHeight != height) {
            sceneWidth = width;
            sceneHeight = height;

            if (stage != null) {
                onStageResize(null);
            }
        }
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
            return sceneWidth;
        }

        @:noCompletion
        @:setter(width)
        private function set_width(value:Float):Void {
            if (sceneWidth != value) {
                sceneWidth = value;
                onStageResize(null);
            }
        }

        @:noCompletion
        @:getter(height)
        private function get_height():Float {
            return sceneHeight;
        }

        @:noCompletion
        @:setter(height)
        private function set_height(value:Float):Void {
            if (sceneHeight != value) {
                sceneHeight = value;
                onStageResize(null);
            }
        }
    #else
        @:noCompletion
        override private function get_width():Float {
            return sceneWidth;
        }

        @:noCompletion
        override private function set_width(value:Float):Float {
            if (sceneWidth != value) {
                sceneWidth = value;
                onStageResize(null);
            }

            return value;
        }

        @:noCompletion
        override private function get_height():Float {
            return sceneHeight;
        }

        @:noCompletion
        override private function set_height(value:Float):Float {
            if (sceneHeight != value) {
                sceneHeight = value;
                onStageResize(null);
            }

            return value;
        }
    #end

    private function updateMask():Void {
        maskShape.graphics.clear();

        if (clippingEnabled && sceneWidth > 0 && sceneHeight > 0) {
            maskShape.graphics.beginFill(0x000000);
            maskShape.graphics.drawRect(0, 0, sceneWidth, sceneHeight);
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
        if (stage.stageWidth < 1 || stage.stageHeight < 1 || sceneWidth < 1 || sceneHeight < 1) {
            x = 0;
            y = 0;
            scaleX = 1.0;
            scaleY = 1.0;
        } else {
            var desiredRatio = sceneWidth / sceneHeight;
            var stageRatio = stage.stageWidth / stage.stageHeight;
            var scale:Float;

            if (stageRatio < desiredRatio) {
                scale = stage.stageWidth / sceneWidth;
                y = Math.round((stage.stageHeight - sceneHeight * scale) / 2);
                x = 0;
            } else {
                scale = stage.stageHeight / sceneHeight;
                x = Math.round((stage.stageWidth - sceneWidth * scale) / 2);
                y = 0;
            }

            scaleX = scale;
            scaleY = scale;
        }

        updateMask();
        dispatchEvent(new Event(Event.RESIZE));
    }
}
