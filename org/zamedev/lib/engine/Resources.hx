package org.zamedev.lib.engine;

import openfl.Assets;

class Resources {
    public var fonts:Map<String, String> = new Map<String, String>();
    public var colors:Map<String, UInt> = new Map<String, UInt>();
    public var strings:Map<String, String> = new Map<String, String>();
    public var dimensions:Map<String, Int> = new Map<String, Int>();

    public function load(locale:String = null):Void {
        fonts = new Map<String, String>();
        colors = new Map<String, UInt>();
        strings = new Map<String, String>();
        dimensions = new Map<String, Int>();

        initialize(locale);

        for (key in fonts.keys()) {
            fonts[key] = Assets.getFont(fonts[key]).fontName;
        }
    }

    private function initialize(locale:String = null):Void {
    }
}
