package org.zamedev.ui.graphics;

import openfl.display.DisplayObject;
import openfl.geom.Point;

class DisplayObjectExt {
    public static function setX<T:DisplayObject>(v : T, x : Float) : T {
        v.x = x;
        return v;
    }

    public static function setY<T:DisplayObject>(v : T, y : Float) : T {
        v.y = y;
        return v;
    }

    public static function getCx(v : DisplayObject) : Float {
        return v.x + v.width / 2;
    }

    public static function setCx<T : DisplayObject>(v : T, cx : Float) : T {
        v.x = cx - v.width / 2;
        return v;
    }

    public static function getCy(v : DisplayObject) : Float {
        return v.y + v.height / 2;
    }

    public static function setCy<T : DisplayObject>(v : T, cy : Float) : T {
        v.y = cy - v.height / 2;
        return v;
    }

    public static function getEx(v : DisplayObject) : Float {
        return v.x + v.width;
    }

    public static function setEx<T : DisplayObject>(v : T, ex : Float) : T {
        v.x = ex - v.width;
        return v;
    }

    public static function getEy(v : DisplayObject) : Float {
        return v.y + v.height;
    }

    public static function setEy<T : DisplayObject>(v : T, ey : Float) : T {
        v.y = ey - v.height;
        return v;
    }

    public static function getCpoint(v : DisplayObject) : Point {
        return new Point(v.x + v.width / 2, v.y + v.height / 2);
    }

    public static function setCpoint<T : DisplayObject>(v : T, point : Point) : T {
        v.x = point.x - v.width / 2;
        v.y = point.y - v.height / 2;
        return v;
    }

    public static function setCxy<T : DisplayObject>(v : T, cx : Float, cy : Float) : T {
        v.x = cx - v.width / 2;
        v.y = cy - v.height / 2;
        return v;
    }

    public static function setScale<T : DisplayObject>(v : T, value : Float) : T {
        v.scaleX = value;
        v.scaleY = value;
        return v;
    }
}
