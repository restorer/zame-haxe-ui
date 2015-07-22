package org.zamedev.ui.widget;

import openfl.events.Event;
import org.zamedev.ui.Context;
import org.zamedev.ui.res.MeasureSpec;

class FullStageFrameLayout extends FrameLayout {
    @:keep
    public function new(context:Context) {
        super(context);
        context.applicationStage.addEventListener(Event.RESIZE, onRootResize);
    }

    override private function measureSelf(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Void {
        var appStage = _context.applicationStage;

        offsetX = - appStage.x / appStage.scaleX;
        offsetY = - appStage.y / appStage.scaleY;

        super.measureSelf(
            MeasureSpec.EXACT(appStage.width + (appStage.x / appStage.scaleX) * 2.0),
            MeasureSpec.EXACT(appStage.height + (appStage.y / appStage.scaleY) * 2.0)
        );
    }

    private function onRootResize(_):Void {
        selfLayout(widthSpec, heightSpec, true);
    }
}
