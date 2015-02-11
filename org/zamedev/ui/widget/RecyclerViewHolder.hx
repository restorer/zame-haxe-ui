package org.zamedev.ui.widget;

import org.zamedev.ui.view.View;

class RecyclerViewHolder {
    public var _view:View;
    public var _viewType:Int;
    public var _visiblePosition:Int;

    public function new(view:View) {
        _view = view;
    }
}
