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

    public function new():Void {
        ttfFontName = null;

        #if bitmapFont
            bitmapFontName = null;
            bitmapFont = null;
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

    public static function parse(value:String):FontExt {
        var result = new FontExt();

        #if bitmapFont
            if (~/\.fnt$/i.match(value)) {
                result.bitmapFontName = value;

                result.bitmapFont = BitmapFont.fromAngelCode(
                    Assets.getBitmapData("font/" + ~/\.fnt$/i.replace(value, ".png")),
                    Xml.parse(Assets.getText("font/" + value))
                );

                return result;
            }
        #end

        result.ttfFontName = Assets.getFont("font/" + value).fontName;
        return result;
    }
}
