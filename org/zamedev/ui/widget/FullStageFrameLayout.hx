package org.zamedev.ui.widget;

import openfl.events.Event;
import org.zamedev.ui.Context;
import org.zamedev.ui.res.MeasureSpec;

class FullStageFrameLayout extends FrameLayout {
    @:keep
    public function new(context : Context) {
        super(context);

        addEventListener(Event.ADDED_TO_STAGE, onFullStageFrameLayoutAddedToApplicationStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onFullStageFrameLayoutRemovedFromApplicationStage);
    }

    override private function measureSelf(widthSpec : MeasureSpec, heightSpec : MeasureSpec) : Void {
        var appStage = _context.applicationStage;

        offsetX = - appStage.x / appStage.scaleX;
        offsetY = - appStage.y / appStage.scaleY;

        super.measureSelf(
            MeasureSpec.EXACT(appStage.width + (appStage.x / appStage.scaleX) * 2.0),
            MeasureSpec.EXACT(appStage.height + (appStage.y / appStage.scaleY) * 2.0)
        );
    }

    private function onFullStageFrameLayoutAddedToApplicationStage(_) : Void {
        context.applicationStage.addEventListener(Event.RESIZE, onRootResize);
    }

    private function onFullStageFrameLayoutRemovedFromApplicationStage(_) : Void {
        context.applicationStage.removeEventListener(Event.RESIZE, onRootResize);
    }

    private function onRootResize(_) : Void {
        selfLayout(widthSpec, heightSpec, true);
    }
}
