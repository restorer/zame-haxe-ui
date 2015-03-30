package org.zamedev.ui.res;

import org.zamedev.ui.Context;
import org.zamedev.ui.errors.UiError;
import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.graphics.FontExt;
import org.zamedev.ui.view.LayoutParams;
import org.zamedev.ui.view.View;

class ResourceManager {
    private var context:Context;
    private var colorMap:Map<Int, Int>;
    private var dimenMap:Map<Int, Dimension>;
    private var stringMap:Map<Int, String>;
    private var fontMap:Map<Int, FontExt>;
    private var drawableMap:Map<Int, Drawable>;
    private var styleMap:Map<Int, Style>;
    private var selectorMap:Map<Int, Selector>;
    private var layoutMap:Map<Int, LayoutParams->ResourceManager->View>;

    public function new(context:Context) {
        this.context = context;
        reload();
    }

    public function reload() {
        colorMap = new Map<Int, Int>();
        dimenMap = new Map<Int, Dimension>();
        stringMap = new Map<Int, String>();
        fontMap = new Map<Int, FontExt>();
        drawableMap = new Map<Int, Drawable>();
        styleMap = new Map<Int, Style>();
        selectorMap = new Map<Int, Selector>();
        layoutMap = new Map<Int, LayoutParams->ResourceManager->View>();

        R._loadInto(this, context.locale);
    }

    public function findIdByName(resName:String):Null<Int> {
        return R.nameToIdMap[resName];
    }

    public function getColor(resId:Int):Int {
        return cast ensureFound(colorMap[resId], resId, "color");
    }

    public function getDimension(resId:Int):Dimension {
        return cast ensureFound(dimenMap[resId], resId, "dimen", "dimension");
    }

    public function getFloat(resId:Int):Float {
        var value = cast ensureFound(dimenMap[resId], resId, "dimen", "dimension");

        switch (value) {
            case EXACT(size):
                return size;

            default:
                throw new UiError('only exact dimensions coul\'d be resolved as float for resource ${resId}');
        }
    }

    public function getDrawable(resId:Int):Drawable {
        return cast ensureFound(drawableMap[resId], resId, "drawable");
    }

    public function getFont(resId:Int):FontExt {
        return cast ensureFound(fontMap[resId], resId, "font");
    }

    public function getSelector(resId:Int):Selector {
        return cast ensureFound(selectorMap[resId], resId, "selector");
    }

    public function getString(resId:Int):String {
        return cast ensureFound(stringMap[resId], resId, "string");
    }

    public function getStyle(resId:Int):Style {
        return cast ensureFound(styleMap[resId], resId, "style");
    }

    private function _getInflateFunc(resId:Int):LayoutParams->ResourceManager->View {
        return cast ensureFound(layoutMap[resId], resId, "layout");
    }

    private function ensureFound(value:Dynamic, resId:Int, refType:String, displayType:String = null):Dynamic {
        if (value != null) {
            return value;
        }

        var resName:String = null;

        for (name in R.nameToIdMap.keys()) {
            if (R.nameToIdMap[name] == resId) {
                resName = '@${name}';
                break;
            }
        }

        if (resName == null) {
            resName = '#${resId}';
        }

        if (displayType == null) {
            displayType = refType;
        }

        throw new UiError('${displayType} resource ${resName} was not found');
    }
}
