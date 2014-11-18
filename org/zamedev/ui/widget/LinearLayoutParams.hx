package org.zamedev.ui.widget;

import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.Gravity;
import org.zamedev.ui.graphics.GravityTools;
import org.zamedev.ui.res.TypedValue;
import org.zamedev.ui.view.LayoutParams;

class LinearLayoutParams extends LayoutParams {
    public var marginLeft:Dimension;
    public var marginRight:Dimension;
    public var marginTop:Dimension;
    public var marginBottom:Dimension;
    public var gravity:Gravity;

    public var _marginLeftComputed:Float;
    public var _marginRightComputed:Float;
    public var _marginTopComputed:Float;
    public var _marginBottomComputed:Float;

    public function new() {
        super();

        marginLeft = Dimension.EXACT(0.0);
        marginRight = Dimension.EXACT(0.0);
        marginTop = Dimension.EXACT(0.0);
        marginBottom = Dimension.EXACT(0.0);
        gravity = Gravity.NONE;

        _marginLeftComputed = 0.0;
        _marginRightComputed = 0.0;
        _marginTopComputed = 0.0;
        _marginBottomComputed = 0.0;
    }

    override public function inflate(name:String, value:TypedValue):Bool {
        if (super.inflate(name, value)) {
            return true;
        }

        switch (name) {
            case "marginLeft":
                marginLeft = value.resolveDimension();
                return true;

            case "marginRight":
                marginRight = value.resolveDimension();
                return true;

            case "marginTop":
                marginTop = value.resolveDimension();
                return true;

            case "marginBottom":
                marginBottom = value.resolveDimension();
                return true;

            case "marginHorizontal":
                marginLeft = value.resolveDimension();
                marginRight = marginLeft;
                return true;

            case "marginVertical":
                marginTop = value.resolveDimension();
                marginBottom = marginTop;
                return true;

            case "margin":
                marginLeft = value.resolveDimension();
                marginRight = marginLeft;
                marginTop = marginLeft;
                marginBottom = marginLeft;
                return true;

            case "gravity":
                gravity = GravityTools.parse(value.resolveString());
                return true;
        }

        return false;
    }
}
