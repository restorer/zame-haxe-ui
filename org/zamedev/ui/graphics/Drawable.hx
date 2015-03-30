package org.zamedev.ui.graphics;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.PixelSnapping;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import org.zamedev.ui.errors.UiError;

class Drawable {
    public var type(default, null):DrawableType;
    public var assetId(default, null):String;
    public var packedX(default, null):Int;
    public var packedY(default, null):Int;
    public var packedW(default, null):Int;
    public var packedH(default, null):Int;

    private var packedBitmapData:BitmapData;

    public function new(type:DrawableType, assetId:String, packedX:Int = 0, packedY:Int = 0, packedW:Int = 0, packedH:Int = 0) {
        this.type = type;
        this.assetId = assetId;
        this.packedX = packedX;
        this.packedY = packedY;
        this.packedW = packedW;
        this.packedH = packedH;

        this.packedBitmapData = null;
    }

    public function toString() {
        return '[Drawable type=${type} assetId=${assetId} packedX=${packedX} packedY=${packedY} packedW=${packedW} packedH=${packedH}]';
    }

    public function computeKey():String {
        return '${Std.string(type)}:${assetId}:${packedX}:${packedY}:${packedW}:${packedH}';
    }

    public function resolve():DisplayObject {
        return new Bitmap(resolveBitmapData(), PixelSnapping.AUTO, true);
    }

    public function resolveBitmapData():BitmapData {
        if (type == DrawableType.BITMAP) {
            return Assets.getBitmapData(assetId);
        }

        if (type == DrawableType.PACKED) {
            if (packedBitmapData == null) {
                packedBitmapData = new BitmapData(packedW, packedH, true, 0);

                packedBitmapData.copyPixels(
                    Assets.getBitmapData(assetId),
                    new Rectangle(packedX, packedY, packedW, packedH),
                    new Point(0, 0),
                    null,
                    null,
                    true
                );
            }

            return packedBitmapData;
        }

        throw new UiError("Unsupported drawable type: " + type);
    }

    public static function eq(a:Drawable, b:Drawable):Bool {
        if (a == null && b == null) {
            return true;
        }

        if (a == null || b == null || a.type != b.type || a.assetId != b.assetId) {
            return false;
        }

        if (a.type == DrawableType.PACKED && (
            a.packedX != b.packedX
            || a.packedY != b.packedY
            || a.packedW != b.packedW
            || a.packedH != b.packedH
        )) {
            return false;
        }

        return true;
    }

    public static function bitmapFromAsset(assetId:String, pixelSnapping:PixelSnapping = null, smoothing:Bool = true):Bitmap {
        if (pixelSnapping == null) {
            pixelSnapping = PixelSnapping.AUTO;
        }

        return new Bitmap(Assets.getBitmapData(assetId), pixelSnapping, smoothing);
    }
}
