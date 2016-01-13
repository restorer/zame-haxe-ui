package org.zamedev.ui.view;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.geom.Point;
import org.zamedev.ui.Context;
import org.zamedev.ui.errors.UiError;
import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.DimensionTools;
import org.zamedev.ui.res.Inflatable;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.Style;
import org.zamedev.ui.res.Styleable;
import org.zamedev.ui.res.StyleableNameMap;

using Lambda;
using StringTools;

@:access(org.zamedev.ui.view.LayoutParams)
class View extends EventDispatcher implements Inflatable {
    private var _context : Context;
    private var _sprite : Sprite;
    private var _width : Float;
    private var _height : Float;
    private var _parent : ViewContainer;
    private var widthSpec : MeasureSpec;
    private var heightSpec : MeasureSpec;
    private var _state : Map<String, Bool>;
    private var _style : Style;
    private var isInLayout : Bool;
    private var _x : Float;
    private var _y : Float;
    private var _offsetX : Float;
    private var _offsetY : Float;
    private var widthWeightSum : Float;
    private var heightWeightSum : Float;
    private var _visibility : ViewVisibility;
    private var isAddedToApplicationStage : Bool;

    public var id : Null<Int>;
    public var tags : Map<String, Dynamic>;
    public var layoutParams : LayoutParams;
    public var state(get, set) : Map<String, Bool>;
    public var style(get, set) : Style;
    public var sprite(get, null) : Sprite;
    public var parent(get, null) : ViewGroup;
    public var x(get, set) : Float;
    public var y(get, set) : Float;
    public var offsetX(get, set) : Float;
    public var offsetY(get, set) : Float;
    public var width(get, null) : Float;
    public var height(get, null) : Float;
    public var cx(get, set) : Float;
    public var cy(get, set) : Float;
    public var ex(get, set) : Float;
    public var ey(get, set) : Float;
    public var xy(get, set) : Point;
    public var offset(get, set) : Point;
    public var cxy(get, set) : Point;
    public var rotation(get, set) : Float;
    public var visibility(get, set) : ViewVisibility;
    public var alpha(get, set) : Float;

    @:keep
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
        _style = null;
        isInLayout = false;
        isAddedToApplicationStage = false;

        id = null;
        tags = new Map<String, Dynamic>();
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

    public function inflate(attId : Styleable, value : Dynamic) : Void {
        if (!_inflate(attId, value)) {
            var attName = StyleableNameMap.getIdToNameMap()[attId];

            if (attName == null) {
                attName = "#" + Std.string(attId);
            }

            throw new UiError('can\'t inflate styleable "${attName}" in "${Type.getClassName(Type.getClass(this))}"');
        }
    }

    private function _inflate(attId : Styleable, value : Dynamic) : Bool {
        if ((cast attId : Int) >= (cast Styleable._layout : Int)) {
            return (layoutParams == null ? false : layoutParams._inflate(attId, value));
        }

        switch (attId) {
            case Styleable.id:
                id = cast value;
                return true;

            case Styleable.tags:
                tags = new Map<String, Dynamic>();

                for (tag in (cast value : Array<String>)) {
                    tags[tag] = true;
                }

                return true;

            case Styleable.style:
                style = cast value;
                return true;

            case Styleable.widthWeightSum:
                widthWeightSum = Math.max(1.0, computeDimension(cast value, false));
                return true;

            case Styleable.heightWeightSum:
                heightWeightSum = Math.max(1.0, computeDimension(cast value, true));
                return true;

            case Styleable.visibility:
                visibility = cast value;
                return true;

            case Styleable.alpha:
                alpha = cast value;
                return true;

            case Styleable.rotation:
                rotation = cast value;
                return true;

            case Styleable.offsetX:
                offsetX = computeDimension(cast value, false);
                return true;

            case Styleable.offsetY:
                offsetY = computeDimension(cast value, true);
                return true;

            default:
                return false;
        }
    }

    public function onInflateStarted() : Void {
        isInLayout = true;
    }

    public function onInflateFinished() : Void {
        isInLayout = false;
    }

    public function addToContainer(container : DisplayObjectContainer) : Void {
        if (_sprite.parent == container) {
            return;
        }

        if (_sprite.parent != null) {
            _sprite.parent.removeChild(_sprite);
        }

        selfLayout(MeasureSpec.EXACT(container.width), MeasureSpec.EXACT(container.height));
        container.addChild(_sprite);
    }

    public function removeFromContainer() : Void {
        if (_sprite.parent != null) {
            _sprite.parent.removeChild(_sprite);
        }
    }

    private function onViewAddedToApplicationStage(_) : Void {
        isAddedToApplicationStage = true;
    }

    private function onViewRemovedFromApplicationStage(_) : Void {
        isAddedToApplicationStage = false;
    }

    public function requestLayout() : Void {
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

    public function selfLayout(widthSpec : MeasureSpec, heightSpec : MeasureSpec, force : Bool = false) : Void {
        if (isInLayout) {
            return;
        }

        isInLayout = true;

        if (force) {
            this.widthSpec = null;
            this.heightSpec = null;
        }

        measureAndLayout(widthSpec, heightSpec);
        isInLayout = false;
    }

    private function measureAndLayout(widthSpec : MeasureSpec, heightSpec : MeasureSpec) : Bool {
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

    private function stateUpdated() : Void {
        if (_style != null && _style.runtimeFunc != null) {
            _style.runtimeFunc(this, _state, _context.resourceManager);
        }
    }

    public function setState(name : String, value : Bool) : View {
        _state = new Map<String, Bool>();
        _state[name] = value;
        stateUpdated();
        return this;
    }

    public function hasState(name : String) : Bool {
        var value = _state[name];
        return (value != null && value);
    }

    public function updateState(name : String, value : Bool) : View {
        var prevValue = _state[name];

        if ((prevValue != null && value != prevValue) || (prevValue == null && value)) {
            _state[name] = value;
            stateUpdated();
        }

        return this;
    }

    private function computeDimension(dimension : Dimension, vertical : Bool) : Float {
        switch (dimension) {
            case Dimension.WRAP_CONTENT | Dimension.MATCH_PARENT:
                throw new UiError("dimension must be exact or relative to stage");

            case Dimension.EXACT(size):
                return size;

            case Dimension.WEIGHT_PARENT(_, _, _):
                throw new UiError("dimension must be exact or relative to stage");

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
    private function get_sprite() : Sprite {
        return _sprite;
    }

    @:noCompletion
    private function get_parent() : ViewGroup {
        return (Std.is(_parent, ViewGroup) ? cast _parent : null);
    }

    @:noCompletion
    private function get_state() : Map<String, Bool> {
        return _state;
    }

    @:noCompletion
    private function set_state(value : Map<String, Bool>) : Map<String, Bool> {
        _state = value;
        stateUpdated();
        return value;
    }

    @:noCompletion
    private function get_style() : Style {
        return _style;
    }

    @:noCompletion
    private function set_style(value : Style) : Style {
        _style = value;

        if (_style != null && _style.staticFunc != null) {
            _style.staticFunc(this, _context.resourceManager);
        }

        stateUpdated();
        return value;
    }

    @:keep
    @:noCompletion
    private function get_x() : Float {
        return _x;
    }

    @:noCompletion
    private function set_x(value : Float) : Float {
        _x = value;
        _sprite.x = value + _offsetX;
        return value;
    }

    @:keep
    @:noCompletion
    private function get_y() : Float {
        return _y;
    }

    @:noCompletion
    private function set_y(value : Float) : Float {
        _y = value;
        _sprite.y = value + _offsetY;
        return value;
    }

    @:keep
    @:noCompletion
    private function get_offsetX() : Float {
        return _offsetX;
    }

    @:keep
    @:noCompletion
    private function set_offsetX(value : Float) : Float {
        _offsetX = value;
        _sprite.x = _x + value;
        return value;
    }

    @:keep
    @:noCompletion
    private function get_offsetY() : Float {
        return _offsetY;
    }

    @:noCompletion
    private function set_offsetY(value : Float) : Float {
        _offsetY = value;
        _sprite.y = _y + value;
        return value;
    }

    @:keep
    @:noCompletion
    private function get_width() : Float {
        return _width;
    }

    @:keep
    @:noCompletion
    private function get_height() : Float {
        return _height;
    }

    @:keep
    @:noCompletion
    private function get_cx() : Float {
        return x + width / 2;
    }

    @:keep
    @:noCompletion
    private function set_cx(value : Float) : Float {
        x = value - width / 2;
        return value;
    }

    @:keep
    @:noCompletion
    private function get_cy() : Float {
        return y + height / 2;
    }

    @:keep
    @:noCompletion
    private function set_cy(value : Float) : Float {
        y = value - height / 2;
        return value;
    }

    @:keep
    @:noCompletion
    private function get_ex() : Float {
        return x + width;
    }

    @:keep
    @:noCompletion
    private function set_ex(value : Float) : Float {
        x = value - width;
        return value;
    }

    @:keep
    @:noCompletion
    private function get_ey() : Float {
        return y + height;
    }

    @:keep
    @:noCompletion
    private function set_ey(value : Float) : Float {
        y = value - height;
        return value;
    }

    @:noCompletion
    private function get_xy() : Point {
        return new Point(x, y);
    }

    @:noCompletion
    private function set_xy(value : Point) : Point {
        x = value.x;
        y = value.y;
        return value;
    }

    @:noCompletion
    private function get_offset() : Point {
        return new Point(offsetX, offsetY);
    }

    @:noCompletion
    private function set_offset(value : Point) : Point {
        offsetX = value.x;
        offsetY = value.y;
        return value;
    }

    @:noCompletion
    private function get_cxy() : Point {
        return new Point(cx, cy);
    }

    @:noCompletion
    private function set_cxy(value : Point) : Point {
        cx = value.x;
        cy = value.y;
        return value;
    }

    @:keep
    @:noCompletion
    private function get_rotation() : Float {
        return _sprite.rotation;
    }

    @:keep
    @:noCompletion
    private function set_rotation(value : Float) : Float {
        _sprite.rotation = value;
        return value;
    }

    @:noCompletion
    private function get_visibility() : ViewVisibility {
        return _visibility;
    }

    @:noCompletion
    private function set_visibility(value : ViewVisibility) : ViewVisibility {
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

    @:keep
    @:noCompletion
    private function get_alpha() : Float {
        return _sprite.alpha;
    }

    @:keep
    @:noCompletion
    private function set_alpha(value : Float) : Float {
        _sprite.alpha = value;
        return value;
    }
}
