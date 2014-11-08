package org.zamedev.lib.engine;

import openfl.display.DisplayObject;

class View {
    public static function setX<T:DisplayObject>(view:T, x:Float):T {
        view.x = x;
        return view;
    }

    public static function setY<T:DisplayObject>(view:T, y:Float):T {
        view.y = y;
        return view;
    }

    public static function setCx<T:DisplayObject>(view:T, cx:Float):T {
        view.x = cx - view.width / 2;
        return view;
    }

    public static function setRx<T:DisplayObject>(view:T, ex:Float):T {
        view.x = ex - view.width;
        return view;
    }

    public static function setCy<T:DisplayObject>(view:T, cy:Float):T {
        view.y = cy - view.height / 2;
        return view;
    }

    public static function setBy<T:DisplayObject>(view:T, ey:Float):T {
        view.y = ey - view.height;
        return view;
    }

    public static function setCxy<T:DisplayObject>(view:T, cx:Float, cy:Float):T {
        view.x = cx - view.width / 2;
        view.y = cy - view.height / 2;
        return view;
    }

    public static function getCx(view:DisplayObject):Float {
        return view.x + view.width / 2;
    }

    public static function getRx(view:DisplayObject):Float {
        return view.x + view.width;
    }

    public static function getCy(view:DisplayObject):Float {
        return view.y + view.height / 2;
    }

    public static function getBy(view:DisplayObject):Float {
        return view.y + view.height;
    }
}
