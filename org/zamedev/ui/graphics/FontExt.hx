package org.zamedev.ui.graphics;

import openfl.Assets;

#if bitmapFont
    import bitmapFont.BitmapFont;
#end

class FontExt {
    public var ttfFontName:String;

    #if bitmapFont
        public var bitmapFontName:String;
        public var bitmapFont:BitmapFont;
    #end

    public function new(ttfFontName:String = null #if bitmapFont , bitmapFontName:String = null, bitmapFont:BitmapFont = null #end):Void {
        this.ttfFontName = ttfFontName;

        #if bitmapFont
            this.bitmapFontName = bitmapFontName;
            this.bitmapFont = bitmapFont;
        #end
    }

    public static function equals(a:FontExt, b:FontExt):Bool {
        if (a == null && b == null) {
            return true;
        }

        if (a == null || b == null) {
            return false;
        }

        #if bitmapFont
            return (a.ttfFontName == b.ttfFontName && a.bitmapFontName == b.bitmapFontName);
        #else
            return (a.ttfFontName == b.ttfFontName);
        #end
    }

    public static function createTtf(assetId:String) {
        return new FontExt(Assets.getFont(assetId).fontName);
    }

    #if bitmapFont
        public static function createBitmap(name:String, imageAssetId:String, xmlAssetId:String) {
            return new FontExt(null, name, BitmapFont.fromAngelCode(
                Assets.getBitmapData(imageAssetId),
                Xml.parse(Assets.getText(xmlAssetId))
            ));
        }
    #end
}
