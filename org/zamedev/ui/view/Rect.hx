package org.zamedev.ui.view;

import openfl.display.Shape;

class Rect extends View {
    private var shape:Shape;
    private var shapeWidth:Float;
    private var shapeHeight:Float;

    public var fillColor(default, set):UInt;

    public function new() {
        super();

        addChild(shape = new Shape());
        shapeWidth = 0.0;
        shapeHeight = 0.0;
        fillColor = 0;
    }

    override public function inflate(name:String, value:TypedValue):Bool {
        if (super.inflate(name, value)) {
            return true;
        }

        switch (name) {
            case "fillColor":
                fillColor = value.resolveColor();
                return true;
        }

        return false;
    }

    private function updateShape():Void {
        shape.graphics.clear();

        if (shapeWidth > 0 && shapeHeight > 0) {
            shape.graphics.beginFill(fillColor);
            shape.graphics.drawRect(0, 0, shapeWidth, shapeHeight);
            shape.graphics.endFill();
        }
    }

    @:noCompletion
    private function set_fillColor(value:UInt):UInt {
        fillColor = value;
        updateShape();
        return value;
    }

    #if !flash override #end private function get_width():Float {
        return shapeWidth;
    }

    #if !flash override #end private function set_width(value:Float):Float {
        shapeWidth = value;
        updateShape();
        measure();
        return value;
    }

    #if !flash override #end private function get_height():Float {
        return shapeHeight;
    }

    #if !flash override #end private function set_height(value:Float):Float {
        shapeHeight = value;
        updateShape();
        measure();
        return value;
    }
}
