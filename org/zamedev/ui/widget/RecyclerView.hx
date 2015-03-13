package org.zamedev.ui.widget;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.display.Shape;
import openfl.errors.Error;
import openfl.events.Event;
import org.zamedev.ui.Context;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.TypedValue;
import org.zamedev.ui.view.LayoutParams;
import org.zamedev.ui.view.View;
import org.zamedev.ui.view.BaseViewContainer;
import org.zamedev.ui.view.ViewVisibility;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;
import motion.Actuate;

using StringTools;

class RecyclerView extends BaseViewContainer {
    private var _adapter:RecyclerViewAdapter;
    private var _attachedList:Array<RecyclerViewHolder>;
    private var _detachedMap:Map<Int, List<RecyclerViewHolder>>;
    private var computedWidth:Float;
    private var computedHeight:Float;
    private var isChangingDataset:Bool;
    private var renderedBitmap:Bitmap;
    private var bitmapData:BitmapData;
    private var renderToBitmap:Bool;
    private var _firstVisiblePosition:Int;
    private var _scrollOffsetX:Float;
    private var _scrollOffsetY:Float;
    private var _cycle:Bool;
    private var _verticalFadeSize:Int;
    private var layoutManager:RecyclerViewLayoutManager;
    private var _isScrolling:Bool;
    private var _scrollable:Bool;

    private var _diffOffsetX:Float;
    private var _diffOffsetY:Float;
    private var _scrollingCurrentOffsetX:Float;
    private var _scrollingCurrentOffsetY:Float;

    public var adapter(get, set):RecyclerViewAdapter;
    public var scrollOffsetX(get, set):Float;
    public var scrollOffsetY(get, set):Float;
    public var cycle(get, set):Bool;
    public var verticalFadeSize(get, set):Int;
    public var scrollable(get, set):Bool;

    @:keep
    public function new(context:Context) {
        super(context);

        _adapter = null;
        _attachedList = new Array<RecyclerViewHolder>();
        _detachedMap = new Map<Int, List<RecyclerViewHolder>>();
        computedWidth = 0.0;
        computedHeight = 0.0;
        isChangingDataset = false;
        renderedBitmap = new Bitmap();
        bitmapData = null;
        renderToBitmap = false;
        _firstVisiblePosition = 0;
        _scrollOffsetX = 0.0;
        _scrollOffsetY = 0.0;
        _cycle = false;
        _verticalFadeSize = 0;
        layoutManager = new RecyclerViewLayoutManager();
        _isScrolling = false;
        _scrollable = true;

        addEventListener(Event.ADDED_TO_STAGE, onRecyclerViewAddedToApplicationStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRecyclerViewRemovedFromApplicationStage);
    }

    override public function inflate(name:String, value:TypedValue):Bool {
        if (super.inflate(name, value)) {
            return true;
        }

        switch (name) {
            case "cycle":
                cycle = value.resolveBool();
                return true;

            case "verticalFadeSize":
                verticalFadeSize = Std.int(computeDimension(value.resolveDimension(), true));
                return true;

            case "scrollable":
                scrollable = value.resolveBool();
                return true;
        }

        return false;
    }

    override private function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
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

            return true;
        }

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

        handleDataSetChanged();

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

            case MeasureSpec.EXACT(_):
        }

        return true;
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
        if (viewHolder._view._sprite.parent == _sprite) {
            _sprite.removeChild(viewHolder._view._sprite);
        }

        _attachedList.remove(viewHolder);

        if (!_detachedMap.exists(viewHolder._viewType)) {
            _detachedMap[viewHolder._viewType] = new List<RecyclerViewHolder>();
        }

        _detachedMap[viewHolder._viewType].push(viewHolder);

        if (isAddedToApplicationStage) {
            viewHolder._view.dispatchEvent(new Event(Event.REMOVED_FROM_STAGE));
        }
    }

    private function attachViewHolder(position:Int, attachToSprite:Bool, addToBegin:Bool):RecyclerViewHolder {
        var viewHolder:RecyclerViewHolder;
        var viewType = _adapter.getItemViewType(position);

        if (_detachedMap.exists(viewType) && !_detachedMap[viewType].isEmpty()) {
            viewHolder = _detachedMap[viewType].pop();
        } else {
            viewHolder = _adapter.onCreateViewHolder(new LayoutParams(), viewType);
            viewHolder._viewType = viewType;
        }

        if (addToBegin) {
            _attachedList.unshift(viewHolder);
        } else {
            _attachedList.push(viewHolder);
        }

        if (attachToSprite) {
            _sprite.addChild(viewHolder._view._sprite);
        }

        viewHolder._visiblePosition = position - _firstVisiblePosition;

        if (isAddedToApplicationStage) {
            viewHolder._view.dispatchEvent(new Event(Event.ADDED_TO_STAGE));
        }

        return viewHolder;
    }

    private function bindViewHolder(viewHolder:RecyclerViewHolder, position:Int):Void {
        viewHolder._view.isInLayout = true;
        _adapter.onBindViewHolder(viewHolder, position);
        viewHolder._view.isInLayout = false;

        var layoutParams = viewHolder._view.layoutParams;
        var widthSpec = computeChildMeasureSpec(layoutParams, layoutParams.width, false);
        var heightSpec = computeChildMeasureSpec(layoutParams, layoutParams.height, true);

        if (widthSpec == null) {
            widthSpec = MeasureSpec.EXACT(0.0);
        }

        if (heightSpec == null) {
            heightSpec = MeasureSpec.EXACT(0.0);
        }

        viewHolder._view.selfLayout(widthSpec, heightSpec, true);
    }

    public function notifyDataSetChanged():Void {
        if (_visibility == ViewVisibility.GONE) {
            return;
        }

        isChangingDataset = true;
        handleDataSetChanged();
        requestLayout();
        isChangingDataset = false;
    }

    private function handleDataSetChanged():Void {
        computedWidth = 0.0;
        computedHeight = 0.0;

        for (viewHolder in _attachedList.copy()) {
            detachViewHolder(viewHolder);
        }

        if (_adapter == null) {
            if (renderedBitmap.parent == _sprite) {
                _sprite.removeChild(renderedBitmap);
            }

            return;
        }

        if (_scrollable) {
            renderToBitmap = true;

            switch (widthSpec) {
                case EXACT(_):
                default: renderToBitmap = false;
            }

            switch (heightSpec) {
                case EXACT(_):
                default: renderToBitmap = false;
            }
        } else {
            renderToBitmap = false;
        }

        if (renderToBitmap) {
            var bitmapWidth:Int = Std.int(Math.max(1, Math.ceil(_width)));
            var bitmapHeight:Int = Std.int(Math.max(1, Math.ceil(_height)));

            if (bitmapData == null || bitmapData.width != bitmapWidth || bitmapData.height != bitmapHeight) {
                bitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, 0);
            }

            if (renderedBitmap.parent == null) {
                _sprite.addChild(renderedBitmap);
            }

            computedWidth = _width;
            computedHeight = _height;

            updateBitmapData();
        } else {
            if (renderedBitmap.parent == _sprite) {
                _sprite.removeChild(renderedBitmap);
            }

            computedWidth = 0.0;
            computedHeight = 0.0;
            layoutManager.init(0.0, 0.0, _width, _height);

            for (position in 0 ... _adapter.getItemCount()) {
                var viewHolder = attachViewHolder(position, true, false);
                bindViewHolder(viewHolder, position);

                var view:View = viewHolder._view;
                layoutManager.layout(view);

                computedWidth = Math.max(computedWidth, view.x + view.width);
                computedHeight = Math.max(computedHeight, view.y + view.height);
            }
        }
    }

    private function prependViewHolder(maxPosition:Int):View {
        if (_firstVisiblePosition == 0) {
            if (_cycle) {
                _firstVisiblePosition = maxPosition - 1;
            } else {
                return null;
            }
        } else {
            _firstVisiblePosition--;
        }

        var viewHolder = attachViewHolder(_firstVisiblePosition, false, true);
        bindViewHolder(viewHolder, _firstVisiblePosition);

        var view:View = viewHolder._view;
        layoutManager.prepend(view);

        return view;
    }

    private function updateBitmapData():Void {
        if (!renderToBitmap || adapter == null) {
            return;
        }

        bitmapData.fillRect(bitmapData.rect, 0);

        var isAfterEnd = false;
        var position = _firstVisiblePosition;
        var maxPosition = adapter.getItemCount();
        var attachedListCopy = _attachedList.copy();

        layoutManager.init(_scrollOffsetX, _scrollOffsetY, _width, _height);

        if (maxPosition > 0) {
            while (layoutManager.canPrepend()) {
                var view = prependViewHolder(maxPosition);

                if (view == null) {
                    break;
                }

                _scrollOffsetX = layoutManager.px;
                _scrollOffsetY = layoutManager.py;

                bitmapData.draw(view._sprite, view._sprite.transform.matrix);
            }
        }

        for (viewHolder in attachedListCopy) {
            if (isAfterEnd) {
                detachViewHolder(viewHolder);
                continue;
            }

            var view:View = viewHolder._view;
            layoutManager.layout(view);

            if (layoutManager.isBeforeStart(view)) {
                detachViewHolder(viewHolder);
                _scrollOffsetX = layoutManager.x;
                _scrollOffsetY = layoutManager.y;
                _firstVisiblePosition++;

                if (_firstVisiblePosition >= maxPosition) {
                    if (_cycle) {
                        _firstVisiblePosition = 0;
                    } else {
                        isAfterEnd = true;
                        continue;
                    }
                }
            }

            bitmapData.draw(view._sprite, view._sprite.transform.matrix);
            isAfterEnd = layoutManager.isAtEnd(view);

            if (isAfterEnd) {
                continue;
            }

            position++;

            if (position >= maxPosition) {
                if (_cycle) {
                    position = 0;
                } else {
                    isAfterEnd = true;
                }
            }
        }

        if (!isAfterEnd && maxPosition > 0) {
            while (true) {
                var viewHolder = attachViewHolder(position, false, false);
                bindViewHolder(viewHolder, position);

                var view:View = viewHolder._view;
                layoutManager.layout(view);
                bitmapData.draw(view._sprite, view._sprite.transform.matrix);

                if (layoutManager.isAtEnd(view)) {
                    break;
                }

                position++;

                if (position >= maxPosition) {
                    if (_cycle) {
                        position = 0;
                    } else {
                        break;
                    }
                }
            }
        }

        if (_verticalFadeSize > 0) {
            var colorTransform = new ColorTransform();
            var rect = new Rectangle(0.0, 0.0, bitmapData.rect.width, 1.0);

            for (i in 0 ... _verticalFadeSize) {
                colorTransform.alphaMultiplier = i / _verticalFadeSize;

                rect.y = i;
                bitmapData.colorTransform(rect, colorTransform);

                rect.y = bitmapData.rect.height - i - 1.0;
                bitmapData.colorTransform(rect, colorTransform);
            }
        }

        renderedBitmap.bitmapData = bitmapData;
        renderedBitmap.smoothing = true;
    }

    public function scrollBy(offsetX:Float, offsetY:Float, duration:Float = 0.0):Void {
        scrollTo(_scrollOffsetX + offsetX, _scrollOffsetY + offsetY, duration);
    }

    public function scrollTo(offsetX:Float, offsetY:Float, duration:Float = 0.0):Void {
        if ((offsetX == _scrollOffsetX && offsetY == _scrollOffsetY) || !renderToBitmap) {
            return;
        }

        ensureScrollingStopped();

        if (duration < 0.0001 || _visibility == ViewVisibility.GONE) {
            _scrollOffsetX = offsetX;
            _scrollOffsetY = offsetY;
            updateBitmapData();
            return;
        }

        _isScrolling = true;
        _diffOffsetX = 0.0;
        _diffOffsetY = 0.0;
        _scrollingCurrentOffsetX = _scrollOffsetX;
        _scrollingCurrentOffsetY = _scrollOffsetY;

        Actuate.tween(this, duration, {
            _scrollingCurrentOffsetX: offsetX,
            _scrollingCurrentOffsetY: offsetY,
        }).onUpdate(_handleScrollUpdate).onComplete(_handleScrollComplete);
    }

    private function ensureScrollingStopped() {
        if (_isScrolling) {
            Actuate.stop(this, null, true);
        }
    }

    private function _handleScrollUpdate():Void {
        _scrollOffsetX = _scrollingCurrentOffsetX + _diffOffsetX;
        _scrollOffsetY = _scrollingCurrentOffsetY + _diffOffsetY;

        var prevScrollOffsetX = _scrollOffsetX;
        var prevScrollOffsetY = _scrollOffsetY;

        updateBitmapData();

        _diffOffsetX += (_scrollOffsetX - prevScrollOffsetX);
        _diffOffsetY += (_scrollOffsetY - prevScrollOffsetY);
    }

    private function _handleScrollComplete():Void {
        _isScrolling = false;
    }

    public function updateFirstVisiblePosition(position:Int):Void {
        if (_firstVisiblePosition == position || adapter == null) {
            return;
        }

        var maxPosition = adapter.getItemCount();

        if (maxPosition <= 0) {
            return;
        }

        if (position < 0 || position >= maxPosition) {
            if (cycle) {
                position = ((position % maxPosition) + maxPosition) % maxPosition;
            } else {
                position = Std.int(Math.min(maxPosition - 1, Math.max(0, position)));
            }
        }

        ensureScrollingStopped();

        _firstVisiblePosition = position;
        _scrollOffsetX = 0.0;
        _scrollOffsetY = 0.0;

        for (viewHolder in _attachedList.copy()) {
            detachViewHolder(viewHolder);
        }

        updateBitmapData();
    }

    public function scrollByDir(dir:Int, duration:Float = 0.0):Void {
        if (dir == 0 || !renderToBitmap || adapter == null || _attachedList.length == 0) {
            return;
        }

        if (dir < -1) {
            dir = -1;
        } else if (dir > 1) {
            dir = 1;
        }

        ensureScrollingStopped();

        if (duration < 0.0001 || _visibility == ViewVisibility.GONE) {
            updateFirstVisiblePosition(_firstVisiblePosition + dir);
            return;
        }

        if (dir > 0) {
            var pos = layoutManager.computeNextScrollPosition(_attachedList[0]._view);
            scrollTo(-pos.x, -pos.y, duration);
        } else {
            layoutManager.init(_scrollOffsetX, _scrollOffsetY, _width, _height);
            var view = prependViewHolder(adapter.getItemCount());

            if (view != null) {
                var pos = layoutManager.computePrevScrollPosition(view);
                _scrollOffsetX = pos.x;
                _scrollOffsetY = pos.y;
                scrollTo(0.0, 0.0, duration);
            }
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
                if (viewHolder._view._sprite.parent == _sprite) {
                    _sprite.removeChild(viewHolder._view._sprite);
                }

                if (isAddedToApplicationStage) {
                    viewHolder._view.dispatchEvent(event);
                }
            }

            _firstVisiblePosition = 0;
            _scrollOffsetX = 0.0;
            _scrollOffsetY = 0.0;
            _isScrolling = false;

            _attachedList = new Array<RecyclerViewHolder>();
            _detachedMap = new Map<Int, List<RecyclerViewHolder>>();
            _adapter = value;

            notifyDataSetChanged();
        }

        return value;
    }

    @:noCompletion
    private function get_firstVisiblePosition():Int {
        return _firstVisiblePosition;
    }

    @:noCompletion
    private function set_firstVisiblePosition(value:Int):Int {
        if (_firstVisiblePosition != value) {
            _firstVisiblePosition = value;
            updateBitmapData();
        }

        return value;
    }

    @:noCompletion
    private function get_scrollOffsetX():Float {
        return _scrollOffsetX;
    }

    @:noCompletion
    private function set_scrollOffsetX(value:Float):Float {
        if (_scrollOffsetX != value) {
            _scrollOffsetX = value;
            updateBitmapData();
        }

        return value;
    }

    @:noCompletion
    private function get_scrollOffsetY():Float {
        return _scrollOffsetY;
    }

    @:noCompletion
    private function set_scrollOffsetY(value:Float):Float {
        if (_scrollOffsetY != value) {
            _scrollOffsetY = value;
            updateBitmapData();
        }

        return value;
    }

    @:noCompletion
    private function get_cycle():Bool {
        return _cycle;
    }

    @:noCompletion
    private function set_cycle(value:Bool):Bool {
        if (_cycle != value) {
            _cycle = value;

            if (!isInLayout) {
                updateBitmapData();
            }
        }

        return value;
    }

    @:noCompletion
    private function get_verticalFadeSize():Int {
        return _verticalFadeSize;
    }

    @:noCompletion
    private function set_verticalFadeSize(value:Int):Int {
        if (_verticalFadeSize != value) {
            _verticalFadeSize = value;

            if (!isInLayout) {
                updateBitmapData();
            }
        }

        return value;
    }

    @:noCompletion
    private function get_scrollable():Bool {
        return _scrollable;
    }

    @:noCompletion
    private function set_scrollable(value:Bool):Bool {
        if (_scrollable != value) {
            _scrollable = value;
            notifyDataSetChanged();
        }

        return value;
    }
}
