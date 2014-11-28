package org.zamedev.ui.view;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.geom.Point;
import org.zamedev.ui.Context;
import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.DimensionTools;
import org.zamedev.ui.res.Inflatable;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.Selector;
import org.zamedev.ui.res.TypedValue;

using StringTools;

class View extends EventDispatcher implements Inflatable {
    private var _context:Context;
    private var _sprite:Sprite;
    private var _width:Float;
    private var _height:Float;
    private var _parent:ViewGroup;
    private var widthSpec:MeasureSpec;
    private var heightSpec:MeasureSpec;
    private var _state:Map<String, Bool>;
    private var _selector:Selector;
    private var isInLayout:Bool;
    private var _x:Float;
    private var _y:Float;
    private var _offsetX:Float;
    private var _offsetY:Float;
    private var widthWeightSum:Float;
    private var heightWeightSum:Float;
    private var _visibility:ViewVisibility;
    private var isAddedToApplicationStage:Bool;

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
    public var visibility(get, set):ViewVisibility;
    public var alpha(get, set):Float;

    public function new(context:Context) {
        super();

        _context = context;
        _sprite = new Sprite();
        _width = 0.0;
        _height = 0.0;
        _parent = null;
        widthSpec = null;
        heightSpec = null;
        _state = new Map<String, Bool>();
        _selector = null;
        isInLayout = false;
        isAddedToApplicationStage = false;

        id = null;
        tag = null;
        layoutParams = null;
        _x = 0.0;
        _y = 0.0;
        _offsetX = 0.0;
        _offsetY = 0.0;
        widthWeightSum = 1.0;
        heightWeightSum = 1.0;
        _visibility = ViewVisibility.VISIBLE;

        addEventListener(Event.ADDED_TO_STAGE, onViewAddedToApplicationStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onViewRemovedFromApplicationStage);
    }

    public function inflate(name:String, value:TypedValue):Bool {
        if (name.substr(0, 7) == "layout_") {
            var layoutName = name.substr(7);

            if (layoutParams != null) {
                return layoutParams.inflate(layoutName, value);
            }

            return false;
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

            case "widthWeightSum":
                widthWeightSum = Math.max(1.0, computeDimension(value.resolveDimension(), false));
                return true;

            case "heightWeightSum":
                heightWeightSum = Math.max(1.0, computeDimension(value.resolveDimension(), true));
                return true;

            case "visibility":
                switch (value.resolveString().trim().toLowerCase()) {
                    case "visible":
                        visibility = ViewVisibility.VISIBLE;

                    case "invisible":
                        visibility = ViewVisibility.INVISIBLE;

                    case "gone":
                        visibility = ViewVisibility.GONE;

                    default:
                        throw new ArgumentError("Unknown visibility value: " + value.resolveString());
                }

                return true;

            case "alpha":
                alpha = value.resolveFloat();
                return true;
        }

        return false;
    }

    public function onInflateStarted():Void {
        isInLayout = true;
    }

    public function onInflateFinished():Void {
        isInLayout = false;
    }

    public function addToContainer(container:DisplayObjectContainer):Void {
        if (_sprite.parent == container) {
            return;
        }

        if (_sprite.parent != null) {
            _sprite.parent.removeChild(_sprite);
        }

        measureAndLayout(MeasureSpec.EXACT(container.width), MeasureSpec.EXACT(container.height));
        container.addChild(_sprite);
    }

    public function removeFromContainer():Void {
        if (_sprite.parent != null) {
            _sprite.parent.removeChild(_sprite);
        }
    }

    private function onViewAddedToApplicationStage(_):Void {
        isAddedToApplicationStage = true;
    }

    private function onViewRemovedFromApplicationStage(_):Void {
        isAddedToApplicationStage = false;
    }

    public function requestLayout():Void {
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

        if (_visibility == ViewVisibility.GONE) {
            _width = 0.0;
            _height = 0.0;
            return true;
        }

        return false;
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

    private function computeDimension(dimension:Dimension, vertical:Bool):Float {
        switch (dimension) {
            case Dimension.WRAP_CONTENT | Dimension.MATCH_PARENT:
                throw new Error("Dimension must be exact or relative to stage");

            case Dimension.EXACT(size):
                return size;

            case Dimension.WEIGHT_PARENT(_, _, _):
                throw new Error("Dimension must be exact or relative to stage");

            case Dimension.WEIGHT_STAGE(weight, type, useWeightSum): {
                var appStage = _context.applicationStage;

                if (DimensionTools.resolveVertical(appStage.width, appStage.height, type, vertical)) {
                    return DimensionTools.resolveWeight(weight, appStage.height, appStage.heightWeightSum, useWeightSum);
                } else {
                    return DimensionTools.resolveWeight(weight, appStage.width, appStage.widthWeightSum, useWeightSum);
                }
            }
        }
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

    @:noCompletion
    private function get_visibility():ViewVisibility {
        return _visibility;
    }

    @:noCompletion
    private function set_visibility(value:ViewVisibility):ViewVisibility {
        if (_visibility != value) {
            _sprite.visible = (value == ViewVisibility.VISIBLE);

            if (_visibility == ViewVisibility.GONE || value == ViewVisibility.GONE) {
                _visibility = value;

                if (_parent != null) {
                    _parent.requestLayout();
                }
            } else {
                _visibility = value;
            }
        }

        return value;
    }

    @:noCompletion
    private function get_alpha():Float {
        return _sprite.alpha;
    }

    @:noCompletion
    private function set_alpha(value:Float):Float {
        _sprite.alpha = value;
        return value;
    }
}
