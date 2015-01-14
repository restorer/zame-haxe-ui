package org.zamedev.ui.widget;

import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.Gravity;
import org.zamedev.ui.graphics.GravityTools;
import org.zamedev.ui.graphics.GravityType;
import org.zamedev.ui.res.TypedValue;
import org.zamedev.ui.view.LayoutParams;

class FrameLayoutParams extends LayoutParams {
    public var gravity:Gravity;
    public var marginLeft:Dimension;
    public var marginRight:Dimension;
    public var marginTop:Dimension;
    public var marginBottom:Dimension;

    public var _marginLeftComputed:Float;
    public var _marginRightComputed:Float;
    public var _marginTopComputed:Float;
    public var _marginBottomComputed:Float;

    public function new(
        width:Dimension = null,
        height:Dimension = null,
        gravity:Gravity = null,
        marginTop:Dimension = null,
        marginRight:Dimension = null,
        marginBottom:Dimension = null,
        marginLeft:Dimension = null
    ) {
        super(width, height);

        this.gravity = (gravity == null ? { horizontalType: GravityType.NONE, verticalType: GravityType.NONE } : gravity);
        this.marginLeft = (marginLeft == null ? Dimension.EXACT(0.0) : marginLeft);
        this.marginRight = (marginRight == null ? Dimension.EXACT(0.0) : marginRight);
        this.marginTop = (marginTop == null ? Dimension.EXACT(0.0) : marginTop);
        this.marginBottom = (marginBottom == null ? Dimension.EXACT(0.0) : marginBottom);

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
