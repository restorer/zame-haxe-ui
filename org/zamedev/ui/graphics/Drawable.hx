package org.zamedev.ui.graphics;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.display.PixelSnapping;
import openfl.errors.Error;

enum DrawableType {
    BITMAP;
}

typedef DrawableSpec = {
    type:DrawableType,
    assetId:String,
};

@:forward(type, assetId)
abstract Drawable(DrawableSpec) from DrawableSpec to DrawableSpec {
    public inline function new(type:DrawableType, assetId:String) {
        this = {
            type: type,
            assetId: assetId,
        };
    }

    @:op(A == B)
    private static inline function equals(a:Drawable, b:Drawable):Bool {
        return ((a == null && b == null) || (a != null && b != null && a.type == b.type && a.assetId == b.assetId));
    }

    public function computeKey():String {
        return Std.string(this.type) + ":" + this.assetId;
    }

    public function resolve():DisplayObject {
        if (this.type == DrawableType.BITMAP) {
            return bitmapFromAsset(this.assetId);
        }

        throw new Error("Unsupported drawable type: " + this.type);
    }

    public static function bitmapFromAsset(assetId:String, pixelSnapping:PixelSnapping = null, smoothing:Bool = true):Bitmap {
        if (pixelSnapping == null) {
            pixelSnapping = PixelSnapping.AUTO;
        }

        return new Bitmap(Assets.getBitmapData(assetId), pixelSnapping, smoothing);
    }
}
