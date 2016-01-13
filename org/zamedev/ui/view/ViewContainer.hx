package org.zamedev.ui.view;

import openfl.events.Event;
import org.zamedev.ui.Context;
import org.zamedev.ui.errors.UiError;

class ViewContainer extends BaseViewContainer {
    public var children : Array<View>;

    @:keep
    public function new(context : Context) {
        super(context);
        children = new Array<View>();

        addEventListener(Event.ADDED_TO_STAGE, onViewContainerAddedToApplicationStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onViewContainerRemovedFromApplicationStage);
    }

    private function _addChild(view : View, reLayout : Bool = false) : Void {
        if (view._parent != null) {
            throw new UiError("View already added to another ViewContainer");
        }

        view._parent = this;
        children.push(view);
        _sprite.addChild(view._sprite);

        if (reLayout) {
            requestLayout();
        }

        if (isAddedToApplicationStage) {
            view.dispatchEvent(new Event(Event.ADDED_TO_STAGE));
        }
    }

    private function _removeChild(view : View, reLayout : Bool = false) : Void {
        if (!children.remove(view)) {
            throw new UiError("View is not added to this ViewContainer");
        }

        _sprite.removeChild(view._sprite);
        view._parent = null;

        if (reLayout) {
            requestLayout();
        }

        if (isAddedToApplicationStage) {
            view.dispatchEvent(new Event(Event.REMOVED_FROM_STAGE));
        }
    }

    private function onViewContainerAddedToApplicationStage(e : Event) : Void {
        for (child in children) {
            child.dispatchEvent(e);
        }
    }

    private function onViewContainerRemovedFromApplicationStage(e : Event) : Void {
        for (child in children) {
            child.dispatchEvent(e);
        }
    }
}
