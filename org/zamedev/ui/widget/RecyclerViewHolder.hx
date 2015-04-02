package org.zamedev.ui.widget;

import org.zamedev.ui.view.View;

class RecyclerViewHolder {
    public var _view:View;
    public var _recyclerView:RecyclerView;
    public var _viewType:Int;
    public var _visiblePosition:Int;

    public function new(view:View) {
        _view = view;
    }

    public function onAttach():Void {
    }

    public function onDetach():Void {
        handleOnDetach();
    }

    private function handleOnDetach():Void {
        _recyclerView._detachViewHolderFinishedInternal(this);
    }
}
