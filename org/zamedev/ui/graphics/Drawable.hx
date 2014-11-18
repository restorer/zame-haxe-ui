package org.zamedev.ui.graphics;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.display.PixelSnapping;
import openfl.errors.Error;

enum DrawableType {
    BITMAP;
}

class Drawable {
    public var type(default, null):DrawableType;
    public var assetId(default, null):String;

    public inline function new(type:DrawableType, assetId:String) {
        this.type = type;
        this.assetId = assetId;
    }

    public function computeKey():String {
        return Std.string(type) + ":" + assetId;
    }

    public function resolve():DisplayObject {
        if (type == DrawableType.BITMAP) {
            return bitmapFromAsset(assetId);
        }

        throw new Error("Unsupported drawable type: " + type);
    }

    public static function eq(a:Drawable, b:Drawable):Bool {
        return ((a == null && b == null) || (a != null && b != null && a.type == b.type && a.assetId == b.assetId));
    }

    public static function bitmapFromAsset(assetId:String, pixelSnapping:PixelSnapping = null, smoothing:Bool = true):Bitmap {
        if (pixelSnapping == null) {
            pixelSnapping = PixelSnapping.AUTO;
        }

        return new Bitmap(Assets.getBitmapData(assetId), pixelSnapping, smoothing);
    }
}
