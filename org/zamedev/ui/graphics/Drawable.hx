package org.zamedev.ui.graphics;

import haxe.Int64;

#if (!compiling_builder)
    import openfl.Assets;
    import openfl.display.Bitmap;
    import openfl.display.BitmapData;
    import openfl.display.DisplayObject;
    import openfl.display.PixelSnapping;
    import openfl.geom.Point;
    import openfl.geom.Rectangle;
#end

class Drawable {
    private static var int64one : Int64 = Int64.make(0, 1);
    private static var customDrawableIndex : Int64 = Int64.make(0, 0);

    public var type(default, null) : DrawableType;

    private var id : String;
    private var packedX : Int;
    private var packedY : Int;
    private var packedW : Int;
    private var packedH : Int;

    #if (!compiling_builder)
        private var bitmapData : BitmapData = null;
    #end

    private function new(type : DrawableType) : Void {
        this.type = type;
    }

    public function toString() {
        return '[Drawable type=${type} id=${id} packedX=${packedX} packedY=${packedY} packedW=${packedW} packedH=${packedH}]';
    }

    public function computeKey():String {
        return '${Std.string(type)}:${id}:${packedX}:${packedY}:${packedW}:${packedH}';
    }

    #if (!compiling_builder)
        public function resolve() : DisplayObject {
            return new Bitmap(resolveBitmapData(), PixelSnapping.AUTO, true);
        }

        public function resolveBitmapData() : BitmapData {
            switch (type) {
                case ASSET_BITMAP: {
                    return Assets.getBitmapData(id);
                }

                case ASSET_PACKED: {
                    if (bitmapData == null) {
                        bitmapData = new BitmapData(packedW, packedH, true, 0);

                        bitmapData.copyPixels(
                            Assets.getBitmapData(id),
                            new Rectangle(packedX, packedY, packedW, packedH),
                            new Point(0, 0),
                            null,
                            null,
                            true
                        );
                    }

                    return bitmapData;
                }

                case BITMAP_DATA: {
                    return bitmapData;
                }
            }
        }
    #end

    public static function equals(a : Drawable, b : Drawable) : Bool {
        if (a == null && b == null) {
            return true;
        }

        if (a == null || b == null || a.type != b.type || a.id != b.id) {
            return false;
        }

        if (a.type == DrawableType.ASSET_PACKED && (
            a.packedX != b.packedX
            || a.packedY != b.packedY
            || a.packedW != b.packedW
            || a.packedH != b.packedH
        )) {
            return false;
        }

        return true;
    }

    public static function fromAssetBitmap(assetId : String) : Drawable {
        var result = new Drawable(DrawableType.ASSET_BITMAP);

        result.id = assetId;
        result.packedX = 0;
        result.packedY = 0;
        result.packedW = 0;
        result.packedH = 0;

        return result;
    }

    public static function fromAssetPacked(assetId : String, packedX : Int, packedY : Int, packedW : Int, packedH : Int) : Drawable {
        var result = new Drawable(DrawableType.ASSET_PACKED);

        result.id = assetId;
        result.packedX = packedX;
        result.packedY = packedY;
        result.packedW = packedW;
        result.packedH = packedH;

        return result;
    }

    #if (!compiling_builder)
        public static function fromBitmapData(bitmapData : BitmapData) : Drawable {
            var result = new Drawable(DrawableType.BITMAP_DATA);

            customDrawableIndex = Int64.add(customDrawableIndex, int64one);
            result.id = Int64.toStr(customDrawableIndex);
            result.bitmapData = bitmapData;

            return result;
        }

        public static function createEmpty(width : Int, height : Int) : Drawable {
            return fromBitmapData(new BitmapData(width, height, true, 0));
        }

        public static function bitmapFromBitmapData(bitmapData : BitmapData, ?pixelSnapping : PixelSnapping, smoothing : Bool = true) : Bitmap {
            if (pixelSnapping == null) {
                pixelSnapping = PixelSnapping.AUTO;
            }

            return new Bitmap(bitmapData, pixelSnapping, smoothing);
        }

        public static function bitmapFromAsset(assetId : String, ?pixelSnapping : PixelSnapping, smoothing : Bool = true) : Bitmap {
            return bitmapFromBitmapData(Assets.getBitmapData(assetId));
        }
    #end
}
