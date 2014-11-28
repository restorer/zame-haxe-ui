package org.zamedev.ui.widget;

import openfl.errors.Error;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import org.zamedev.ui.Context;
import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.GravityType;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.TypedValue;
import org.zamedev.ui.view.LayoutParams;
import org.zamedev.ui.view.View;
import org.zamedev.ui.view.ViewGroup;

using StringTools;

class RecyclerView extends ViewGroup {
    private var _adapter:RecyclerViewAdapter;
    private var _attachedList:List<RecyclerViewHolder>;
    private var _detachedMap:Map<Int, List<RecyclerViewHolder>>;
    private var computedWidth:Float;
    private var computedHeight:Float;
    private var isChangingDataset:Bool;

    public var adapter(get, set):RecyclerViewAdapter;

    public function new(context:Context) {
        super(context);

        _adapter = null;
        _attachedList = new List<RecyclerViewHolder>();
        _detachedMap = new Map<Int, List<RecyclerViewHolder>>();
        computedWidth = 0.0;
        computedHeight = 0.0;
        isChangingDataset = false;

        addEventListener(Event.ADDED_TO_STAGE, onRecyclerViewAddedToApplicationStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRecyclerViewRemovedFromApplicationStage);
    }

    override public function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
        if (super.measureAndLayout(widthSpec, heightSpec)) {
            return true;
        }

        if (isChangingDataset) {
            switch (widthSpec) {
                case MeasureSpec.UNSPECIFIED:
                    _width = computedWidth;

                case MeasureSpec.AT_MOST(size):
                    _width = Math.min(size, computedWidth);

                case MeasureSpec.EXACT(size):
                    _width = size;
            }

            switch (heightSpec) {
                case MeasureSpec.UNSPECIFIED:
                    _height = computedHeight;

                case MeasureSpec.AT_MOST(size):
                    _height = Math.min(size, computedHeight);

                case MeasureSpec.EXACT(size):
                    _height = size;
            }
        } else {
            switch (widthSpec) {
                case MeasureSpec.UNSPECIFIED | MeasureSpec.AT_MOST(_):
                    _width = 0.0;

                case MeasureSpec.EXACT(size):
                    _width = size;
            }

            switch (heightSpec) {
                case MeasureSpec.UNSPECIFIED | MeasureSpec.AT_MOST(_):
                    _height = 0.0;

                case MeasureSpec.EXACT(size):
                    _height = size;
            }

            computedWidth = 0.0;
            computedHeight = 0.0;
            _handleDataSetChanged();

            switch (widthSpec) {
                case MeasureSpec.UNSPECIFIED:
                    _width = computedWidth;

                case MeasureSpec.AT_MOST(size):
                    _width = Math.min(size, computedWidth);

                case MeasureSpec.EXACT(_):
            }

            switch (heightSpec) {
                case MeasureSpec.UNSPECIFIED:
                    _height = computedHeight;

                case MeasureSpec.AT_MOST(size):
                    _height = Math.min(size, computedHeight);

                case MeasureSpec.EXACT(size):
            }
        }

        return true;
    }

    override public function findViewById(id:String, deep:Bool = true):View {
        return null;
    }

    override public function findViewsByTag(tag:String, deep:Bool = true):Array<View> {
        return new Array<View>();
    }

    override public function addChild(view:View, reLayout:Bool = true):Void {
        throw new Error("Not supported by RecyclerView");
    }

    override public function removeChild(view:View, reLayout:Bool = true):Void {
        throw new Error("Not supported by RecyclerView");
    }

    private function onRecyclerViewAddedToApplicationStage(e:Event):Void {
        for (viewHolder in _attachedList) {
            viewHolder._view.dispatchEvent(e);
        }
    }

    private function onRecyclerViewRemovedFromApplicationStage(e:Event):Void {
        for (viewHolder in _attachedList) {
            viewHolder._view.dispatchEvent(e);
        }
    }

    private function detachViewHolder(viewHolder:RecyclerViewHolder):Void {
        _sprite.removeChild(viewHolder._view._sprite);
        _attachedList.remove(viewHolder);

        if (!_detachedMap.exists(viewHolder._viewType)) {
            _detachedMap[viewHolder._viewType] = new List<RecyclerViewHolder>();
        }

        _detachedMap[viewHolder._viewType].push(viewHolder);

        if (isAddedToApplicationStage) {
            viewHolder._view.dispatchEvent(new Event(Event.REMOVED_FROM_STAGE));
        }
    }

    private function attachViewHolder(position:Int):RecyclerViewHolder {
        var viewHolder:RecyclerViewHolder;
        var viewType = _adapter.getItemViewType(position);

        if (_detachedMap.exists(viewType) && !_detachedMap[viewType].isEmpty()) {
            viewHolder = _detachedMap[viewType].pop();
        } else {
            viewHolder = _adapter.onCreateViewHolder(new LayoutParams(), viewType);
        }

        _attachedList.push(viewHolder);
        _sprite.addChild(viewHolder._view._sprite);

        if (isAddedToApplicationStage) {
            viewHolder._view.dispatchEvent(new Event(Event.ADDED_TO_STAGE));
        }

        return viewHolder;
    }

    public function notifyDataSetChanged():Void {
        isChangingDataset = true;
        _handleDataSetChanged();
        requestLayout();
        isChangingDataset = false;
    }

    private function _handleDataSetChanged():Void {
        for (viewHolder in _attachedList) {
            detachViewHolder(viewHolder);
        }

        if (_adapter == null) {
            return;
        }

        var x:Float = 0.0;
        var y:Float = 0.0;

        computedWidth = 0.0;
        computedHeight = 0.0;

        for (position in 0 ... _adapter.getItemCount()) {
            var viewHolder = attachViewHolder(position);
            _adapter.onBindViewHolder(viewHolder, position);

            var layoutParams = viewHolder._view.layoutParams;
            var widthSpec = computeChildMeasureSpec(layoutParams, layoutParams.width, false);
            var heightSpec = computeChildMeasureSpec(layoutParams, layoutParams.height, true);

            if (widthSpec == null) {
                widthSpec = MeasureSpec.EXACT(0.0);
            }

            if (heightSpec == null) {
                heightSpec = MeasureSpec.EXACT(0.0);
            }

            viewHolder._view.measureAndLayout(widthSpec, heightSpec);

            viewHolder._view.x = x;
            viewHolder._view.y = y;

            y += viewHolder._view._height;

            computedWidth = Math.max(computedWidth, x + viewHolder._view.width);
            computedHeight = Math.max(computedHeight, y + viewHolder._view.height);
        }
    }

    @:noCompletion
    private function get_adapter():RecyclerViewAdapter {
        return _adapter;
    }

    @:noCompletion
    private function set_adapter(value:RecyclerViewAdapter):RecyclerViewAdapter {
        if (_adapter != value) {
            var event = new Event(Event.REMOVED_FROM_STAGE);

            for (viewHolder in _attachedList) {
                _sprite.removeChild(viewHolder._view._sprite);

                if (isAddedToApplicationStage) {
                    viewHolder._view.dispatchEvent(event);
                }
            }

            _attachedList = new List<RecyclerViewHolder>();
            _detachedMap = new Map<Int, List<RecyclerViewHolder>>();
            _adapter = value;

            notifyDataSetChanged();
        }

        return value;
    }
}
