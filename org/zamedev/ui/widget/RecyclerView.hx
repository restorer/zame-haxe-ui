package org.zamedev.ui.widget;

import openfl.errors.Error;
import openfl.errors.ArgumentError;
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
    private var _activeList:List<RecyclerViewHolder>;
    private var _inactiveMap:Map<Int, List<RecyclerViewHolder>>;

    public var adapter(get, set):RecyclerViewAdapter;

    public function new(context:Context) {
        super(context);

        _adapter = null;
        _activeList = new List<RecyclerViewHolder>();
        _inactiveMap = new Map<Int, List<RecyclerViewHolder>>();
    }

    override public function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
        if (super.measureAndLayout(widthSpec, heightSpec)) {
            return true;
        }

        switch (widthSpec) {
            case MeasureSpec.UNSPECIFIED | MeasureSpec.AT_MOST(_):
                _width = 100;

            case MeasureSpec.EXACT(size):
                _width = size;
        }

        switch (heightSpec) {
            case MeasureSpec.UNSPECIFIED | MeasureSpec.AT_MOST(_):
                _height = 100;

            case MeasureSpec.EXACT(size):
                _height = size;
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

    private function detachViewHolder(viewHolder:RecyclerViewHolder):Void {
        _sprite.removeChild(viewHolder._view._sprite);
        _activeList.remove(viewHolder);

        if (!_inactiveMap.exists(viewHolder._viewType)) {
            _inactiveMap[viewHolder._viewType] = new List<RecyclerViewHolder>();
        }

        _inactiveMap[viewHolder._viewType].push(viewHolder);
    }

    private function attachViewHolder(position:Int):RecyclerViewHolder {
        var viewType = _adapter.getItemViewType(position);

        if (_inactiveMap.exists(viewType) && !_inactiveMap[viewType].isEmpty()) {
            return _inactiveMap[viewType].pop();
        }

        var viewHolder = _adapter.onCreateViewHolder(new LayoutParams(), viewType);
        _activeList.push(viewHolder);
        _sprite.addChild(viewHolder._view._sprite);

        return viewHolder;
    }

    public function notifyDataSetChanged():Void {
        for (viewHolder in _activeList) {
            detachViewHolder(viewHolder);
        }

        if (_adapter == null) {
            return;
        }

        var x:Float = 0.0;
        var y:Float = 0.0;

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
        }
    }

    @:noCompletion
    private function get_adapter():RecyclerViewAdapter {
        return _adapter;
    }

    @:noCompletion
    private function set_adapter(value:RecyclerViewAdapter):RecyclerViewAdapter {
        if (_adapter != value) {
            _adapter = value;
            notifyDataSetChanged();
        }

        return value;
    }
}
