package org.zamedev.ui.widget;

import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.Gravity;
import org.zamedev.ui.graphics.GravityType;
import org.zamedev.ui.res.Styleable;
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

    override private function _inflate(attId:Styleable, value:Dynamic):Bool {
        if (super._inflate(attId, value)) {
            return true;
        }

        switch (attId) {
            case Styleable.layout_marginLeft:
                marginLeft = cast value;
                return true;

            case Styleable.layout_marginRight:
                marginRight = cast value;
                return true;

            case Styleable.layout_marginTop:
                marginTop = cast value;
                return true;

            case Styleable.layout_marginBottom:
                marginBottom = cast value;
                return true;

            case Styleable.layout_marginHorizontal:
                marginLeft = cast value;
                marginRight = marginLeft;
                return true;

            case Styleable.layout_marginVertical:
                marginTop = cast value;
                marginBottom = marginTop;
                return true;

            case Styleable.layout_margin:
                marginLeft = cast value;
                marginRight = marginLeft;
                marginTop = marginLeft;
                marginBottom = marginLeft;
                return true;

            case Styleable.layout_gravity:
                gravity = cast value;
                return true;

            default:
                return false;
        }
    }
}
