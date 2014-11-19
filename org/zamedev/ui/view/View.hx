package org.zamedev.ui.view;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.events.EventDispatcher;
import openfl.geom.Point;
import org.zamedev.ui.res.Inflatable;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.Selector;
import org.zamedev.ui.res.TypedValue;

class View extends EventDispatcher implements Inflatable {
    private var _sprite:Sprite;
    private var _width:Float;
    private var _height:Float;
    private var _parent:ViewGroup;
    private var widthSpec:MeasureSpec;
    private var heightSpec:MeasureSpec;
    private var _state:Map<String, Bool>;
    private var _selector:Selector;
    private var isInLayout:Bool;
    private var inflateFinished:Bool;
    private var layoutParamsMap:Map<String, TypedValue>;
    private var _x:Float;
    private var _y:Float;
    private var _offsetX:Float;
    private var _offsetY:Float;

    public var id:String;
    public var tag:String;
    public var layoutParams:LayoutParams;
    public var state(get, set):Map<String, Bool>;
    public var selector(get, set):Selector;
    public var sprite(get, null):Sprite;
    public var parent(get, null):ViewGroup;
    public var x(get, set):Float;
    public var y(get, set):Float;
    public var offsetX(get, set):Float;
    public var offsetY(get, set):Float;
    public var width(get, null):Float;
    public var height(get, null):Float;
    public var cx(get, set):Float;
    public var cy(get, set):Float;
    public var ex(get, set):Float;
    public var ey(get, set):Float;
    public var xy(get, set):Point;
    public var offset(get, set):Point;
    public var cxy(get, set):Point;
    public var rotation(get, set):Float;

    public function new() {
        super();

        _sprite = new Sprite();
        _width = 0.0;
        _height = 0.0;
        _parent = null;
        widthSpec = null;
        heightSpec = null;
        _state = new Map<String, Bool>();
        _selector = null;
        isInLayout = false;
        inflateFinished = false;
        layoutParamsMap = new Map<String, TypedValue>();

        id = null;
        tag = null;
        layoutParams = null;
        _x = 0.0;
        _y = 0.0;
        _offsetX = 0.0;
        _offsetY = 0.0;
    }

    public function inflate(name:String, value:TypedValue):Bool {
        if (name.substr(0, 7) == "layout_") {
            var layoutName = name.substr(7);
            layoutParamsMap[layoutName] = value;

            if (layoutParams != null) {
                layoutParams.inflate(layoutName, value);
            }

            return true;
        }

        switch (name) {
            case "id":
                id = value.resolveString();
                return true;

            case "tag":
                tag = value.resolveString();
                return true;

            case "selector":
                selector = value.resolveSelector();
                return true;
        }

        return false;
    }

    public function onInflateFinished():Void {
        inflateFinished = true;
    }

    private function inflateLayoutParams(layoutParams:LayoutParams) {
        this.layoutParams = layoutParams;

        for (name in layoutParamsMap.keys()) {
            if (!layoutParams.inflate(name, layoutParamsMap[name])) {
                throw new Error("Parse error: unsupported layout param " + name);
            }
        }
    }

    public function addToContainer(container:DisplayObjectContainer):Void {
        if (_sprite.parent == container) {
            return;
        }

        if (_sprite.parent != null) {
            _sprite.parent.removeChild(_sprite);
        }

        measureAndLayout(MeasureSpec.AT_MOST(container.width), MeasureSpec.AT_MOST(container.height));
        container.addChild(_sprite);
    }

    public function removeFromContainer():Void {
        if (_sprite.parent != null) {
            _sprite.parent.removeChild(_sprite);
        }
    }

    public function requestLayout() {
        if (isInLayout || this.widthSpec == null || this.heightSpec == null) {
            return;
        }

        isInLayout = true;

        var prevWidth = _width;
        var prevHeight = _height;
        var widthSpec = this.widthSpec;
        var heightSpec = this.heightSpec;

        this.widthSpec = null;
        this.heightSpec = null;

        measureAndLayout(widthSpec, heightSpec);

        if (_parent != null && (prevWidth != _width || prevHeight != _height)) {
            _parent.requestLayout();
        }

        isInLayout = false;
    }

    private function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
        if (Type.enumEq(widthSpec, this.widthSpec) && Type.enumEq(heightSpec, this.heightSpec)) {
            return true;
        }

        this.widthSpec = widthSpec;
        this.heightSpec = heightSpec;
        return false;
    }

    private function measureAndLayoutDefault(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Void {
        switch (widthSpec) {
            case MeasureSpec.UNSPECIFIED:
                _width = _sprite.width;

            case MeasureSpec.EXACT(size):
                _width = size;

            case MeasureSpec.AT_MOST(size):
                _width = Math.min(size, _sprite.width);
        }

        switch (heightSpec) {
            case MeasureSpec.UNSPECIFIED:
                _height = _sprite.height;

            case MeasureSpec.EXACT(size):
                _height = size;

            case MeasureSpec.AT_MOST(size):
                _height = Math.min(size, _sprite.height);
        }
    }

    private function stateUpdated():Void {
        if (selector == null) {
            return;
        }

        var map = selector.match(state);

        for (name in map.keys()) {
            inflate(name, map[name]);
        }
    }

    public function setState(name:String, value:Bool):View {
        _state = new Map<String, Bool>();
        _state[name] = value;
        stateUpdated();
        return this;
    }

    public function hasState(name:String):Bool {
        var value = _state[name];
        return (value != null && value);
    }

    public function updateState(name:String, value:Bool):View {
        var prevValue = _state[name];

        if ((prevValue != null && value != prevValue) || (prevValue == null && value)) {
            _state[name] = value;
            stateUpdated();
        }

        return this;
    }

    @:noCompletion
    private function get_sprite():Sprite {
        return _sprite;
    }

    @:noCompletion
    private function get_parent():ViewGroup {
        return _parent;
    }

    @:noCompletion
    private function get_state():Map<String, Bool> {
        return _state;
    }

    @:noCompletion
    private function set_state(value:Map<String, Bool>):Map<String, Bool> {
        _state = value;
        stateUpdated();
        return value;
    }

    @:noCompletion
    private function get_selector():Selector {
        return _selector;
    }

    @:noCompletion
    private function set_selector(value:Selector):Selector {
        _selector = value;
        stateUpdated();
        return value;
    }

    @:noCompletion
    private function get_x():Float {
        return _x;
    }

    @:noCompletion
    private function set_x(value:Float):Float {
        _x = value;
        _sprite.x = value + _offsetX;
        return value;
    }

    @:noCompletion
    private function get_y():Float {
        return _y;
    }

    @:noCompletion
    private function set_y(value:Float):Float {
        _y = value;
        _sprite.y = value + _offsetY;
        return value;
    }

    @:noCompletion
    private function get_offsetX():Float {
        return _offsetX;
    }

    @:noCompletion
    private function set_offsetX(value:Float):Float {
        _offsetX = value;
        _sprite.x = _x + value;
        return value;
    }

    @:noCompletion
    private function get_offsetY():Float {
        return _offsetY;
    }

    @:noCompletion
    private function set_offsetY(value:Float):Float {
        _offsetY = value;
        _sprite.y = _y + value;
        return value;
    }

    @:noCompletion
    private function get_width():Float {
        return _width;
    }

    @:noCompletion
    private function get_height():Float {
        return _height;
    }

    @:noCompletion
    private function get_cx():Float {
        return x + width / 2;
    }

    @:noCompletion
    private function set_cx(value:Float):Float {
        x = value - width / 2;
        return value;
    }

    @:noCompletion
    private function get_cy():Float {
        return y + height / 2;
    }

    @:noCompletion
    private function set_cy(value:Float):Float {
        y = value - height / 2;
        return value;
    }

    @:noCompletion
    private function get_ex():Float {
        return x + width;
    }

    @:noCompletion
    private function set_ex(value:Float):Float {
        x = value - width;
        return value;
    }

    @:noCompletion
    private function get_ey():Float {
        return y + height;
    }

    @:noCompletion
    private function set_ey(value:Float):Float {
        y = value - height;
        return value;
    }

    @:noCompletion
    private function get_xy():Point {
        return new Point(x, y);
    }

    @:noCompletion
    private function set_xy(value:Point):Point {
        x = value.x;
        y = value.y;
        return value;
    }

    @:noCompletion
    private function get_offset():Point {
        return new Point(offsetX, offsetY);
    }

    @:noCompletion
    private function set_offset(value:Point):Point {
        offsetX = value.x;
        offsetY = value.y;
        return value;
    }

    @:noCompletion
    private function get_cxy():Point {
        return new Point(cx, cy);
    }

    @:noCompletion
    private function set_cxy(value:Point):Point {
        cx = value.x;
        cy = value.y;
        return value;
    }

    @:noCompletion
    private function get_rotation():Float {
        return _sprite.rotation;
    }

    @:noCompletion
    private function set_rotation(value:Float):Float {
        _sprite.rotation = value;
        return value;
    }
}
