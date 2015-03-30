package org.zamedev.ui.widget;

import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.res.Styleable;
import org.zamedev.ui.view.LayoutParams;

class AbsoluteLayoutParams extends LayoutParams {
    public var x:Dimension;
    public var y:Dimension;
    public var cx:Dimension;
    public var cy:Dimension;
    public var ex:Dimension;
    public var ey:Dimension;

    public function new(
        width:Dimension = null,
        height:Dimension = null,
        x:Dimension = null,
        y:Dimension = null,
        cx:Dimension = null,
        cy:Dimension = null,
        ex:Dimension = null,
        ey:Dimension = null
    ) {
        super(width, height);

        this.x = x;
        this.y = y;
        this.cx = cx;
        this.cy = cy;
        this.ex = ex;
        this.ey = ey;
    }

    override private function _inflate(attId:Styleable, value:Dynamic):Bool {
        if (super._inflate(attId, value)) {
            return true;
        }

        switch (attId) {
            case Styleable.layout_x:
                x = cast value;
                return true;

            case Styleable.layout_y:
                y = cast value;
                return true;

            case Styleable.layout_cx:
                cx = cast value;
                return true;

            case Styleable.layout_cy:
                cy = cast value;
                return true;

            case Styleable.layout_ex:
                ex = cast value;
                return true;

            case Styleable.layout_ey:
                ey = cast value;
                return true;

            default:
                return false;
        }
    }
}
