package org.zamedev.ui.widget;

import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.res.TypedValue;
import org.zamedev.ui.view.LayoutParams;

class AbsoluteLayoutParams extends LayoutParams {
    public var x:Dimension;
    public var y:Dimension;
    public var cx:Dimension;
    public var cy:Dimension;
    public var ex:Dimension;
    public var ey:Dimension;

    public function new() {
        super();

        x = null;
        y = null;
        cx = null;
        cy = null;
        ex = null;
        ey = null;
    }

    override public function inflate(name:String, value:TypedValue):Bool {
        if (super.inflate(name, value)) {
            return true;
        }

        switch (name) {
            case "x":
                x = value.resolveDimension();
                return true;

            case "y":
                y = value.resolveDimension();
                return true;

            case "cx":
                cx = value.resolveDimension();
                return true;

            case "cy":
                cy = value.resolveDimension();
                return true;

            case "ex":
                ex = value.resolveDimension();
                return true;

            case "ey":
                ey = value.resolveDimension();
                return true;
        }

        return false;
    }
}
