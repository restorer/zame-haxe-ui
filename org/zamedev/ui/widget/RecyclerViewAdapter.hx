package org.zamedev.ui.widget;

import org.zamedev.ui.Context;
import org.zamedev.ui.view.LayoutParams;

class RecyclerViewAdapter {
    private var context : Context;

    public function new(context : Context) {
        this.context = context;
    }

    public function getItemCount() : Int {
        return 0;
    }

    public function getItemId(position : Int) : String {
        return null;
    }

    public function getItemViewType(position : Int) : Int {
        return 0;
    }

    public function onCreateViewHolder(layoutParams : LayoutParams, viewType : Int) : RecyclerViewHolder {
        return null;
    }

    public function onBindViewHolder(viewHolder : RecyclerViewHolder, position : Int) : Void {
    }
}
