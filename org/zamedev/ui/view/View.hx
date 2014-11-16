package org.zamedev.ui.view;

import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.geom.Point;
import org.zamedev.ui.res.Inflatable;
import org.zamedev.ui.res.Selector;
import org.zamedev.ui.res.TypedValue;

class View extends Sprite implements Inflatable {
    private var _state:Map<String, Bool>;
    private var _selector:Selector;
    private var prevWidth:Float;
    private var prevHeight:Float;
    private var inMeasure:Bool;

    public var id:String;
    public var layoutParams:Map<String, TypedValue>;
    public var state(get, set):Map<String, Bool>;
    public var selector(get, set):Selector;

    public var offset(get, set):Point;
    public var offsetX(get, set):Float;
    public var offsetY(get, set):Float;
    public var cx(get, set):Float;
    public var cy(get, set):Float;
    public var ex(get, set):Float;
    public var ey(get, set):Float;
    public var cpoint(get, set):Point;

    public function new() {
        super();

        _state = new Map<String, Bool>();
        _selector = null;
        prevWidth = 0.0;
        prevHeight = 0.0;
        inMeasure = false;
        layoutParams = new Map<String, TypedValue>();
    }

    public function inflate(name:String, value:TypedValue):Bool {
        if (name.substr(0, 7) == "layout_") {
            layoutParams[name.substr(7)] = value;
            return true;
        }

        switch (name) {
            case "id":
                id = value.resolveString();
                return true;
        }

        return false;
    }

    public function measure(child:View = null):Void {
        if (inMeasure) {
            return;
        }

        inMeasure = true;
        onMeasure(child);

        if (prevWidth != width || prevHeight != height) {
            prevWidth = width;
            prevHeight = height;

            if (parent != null && Std.is(parent, View)) {
                cast(parent, View).measure(this);
            }
        }

        inMeasure = false;
    }

    public function onMeasure(child:View = null):Void {
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

    public function updateState(name:String, value:Bool):View {
        var prevValue = _state[name];

        if ((prevValue != null && value != prevValue) || (prevValue == null && value)) {
            _state[name] = value;
            stateUpdated();
        }

        return this;
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
    private function get_offset():Point {
        return new Point(transform.matrix.tx, transform.matrix.ty);
    }

    @:noCompletion
    private function set_offset(value:Point):Point {
        var matrix = transform.matrix;
        matrix.tx = value.x;
        matrix.ty = value.y;
        transform.matrix = matrix;

        return value;
    }

    @:noCompletion
    private function get_offsetX():Float {
        return transform.matrix.tx;
    }

    @:noCompletion
    private function set_offsetX(value:Float):Float {
        var matrix = transform.matrix;
        matrix.tx = value;
        transform.matrix = matrix;

        return value;
    }

    @:noCompletion
    private function get_offsetY():Float {
        return transform.matrix.ty;
    }

    @:noCompletion
    private function set_offsetY(value:Float):Float {
        var matrix = transform.matrix;
        matrix.ty = value;
        transform.matrix = matrix;

        return value;
    }

    @:noCompletion
    private function get_cx():Float {
        return getCx(this);
    }

    @:noCompletion
    private function set_cx(value:Float):Float {
        setCx(this, value);
        return value;
    }

    @:noCompletion
    private function get_cy():Float {
        return getCy(this);
    }

    @:noCompletion
    private function set_cy(value:Float):Float {
        setCy(this, value);
        return value;
    }

    @:noCompletion
    private function get_ex():Float {
        return getEx(this);
    }

    @:noCompletion
    private function set_ex(value:Float):Float {
        setEx(this, value);
        return value;
    }

    @:noCompletion
    private function get_ey():Float {
        return getEy(this);
    }

    @:noCompletion
    private function set_ey(value:Float):Float {
        setEy(this, value);
        return value;
    }

    @:noCompletion
    private function get_cpoint():Point {
        return getCpoint(this);
    }

    @:noCompletion
    private function set_cpoint(value:Point):Point {
        setCpoint(this, value);
        return value;
    }

    public static function setX<T:DisplayObject>(view:T, x:Float):T {
        view.x = x;
        return view;
    }

    public static function setY<T:DisplayObject>(view:T, y:Float):T {
        view.y = y;
        return view;
    }

    public static function getCx(view:DisplayObject):Float {
        return view.x + view.width / 2;
    }

    public static function setCx<T:DisplayObject>(view:T, cx:Float):T {
        view.x = cx - view.width / 2;
        return view;
    }

    public static function getCy(view:DisplayObject):Float {
        return view.y + view.height / 2;
    }

    public static function setCy<T:DisplayObject>(view:T, cy:Float):T {
        view.y = cy - view.height / 2;
        return view;
    }

    public static function getEx(view:DisplayObject):Float {
        return view.x + view.width;
    }

    public static function setEx<T:DisplayObject>(view:T, ex:Float):T {
        view.x = ex - view.width;
        return view;
    }

    public static function getEy(view:DisplayObject):Float {
        return view.y + view.height;
    }

    public static function setEy<T:DisplayObject>(view:T, ey:Float):T {
        view.y = ey - view.height;
        return view;
    }

    public static function getCpoint(view:DisplayObject):Point {
        return new Point(view.x + view.width / 2, view.y + view.height / 2);
    }

    public static function setCpoint<T:DisplayObject>(view:T, point:Point):T {
        view.x = point.x - view.width / 2;
        view.y = point.y - view.height / 2;
        return view;
    }

    public static function setCxy<T:DisplayObject>(view:T, cx:Float, cy:Float):T {
        view.x = cx - view.width / 2;
        view.y = cy - view.height / 2;
        return view;
    }
}
