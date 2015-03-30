package org.zamedev.ui.view;

import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.Styleable;

class LayoutParams {
    public var width:Dimension;
    public var height:Dimension;

    public var _widthSpec:MeasureSpec;
    public var _heightSpec:MeasureSpec;
    public var _measured:Bool;
    public var _measuredWidth:Float;
    public var _measuredHeight:Float;

    public function new(width:Dimension = null, height:Dimension = null) {
        this.width = (width == null ? Dimension.WRAP_CONTENT : width);
        this.height = (height == null ? Dimension.WRAP_CONTENT : height);
    }

    private function _inflate(attId:Styleable, value:Dynamic):Bool {
        switch (attId) {
            case Styleable.layout_width:
                width = cast value;
                return true;

            case Styleable.layout_height:
                height = cast value;
                return true;

            default:
                return false;
        }
    }
}
