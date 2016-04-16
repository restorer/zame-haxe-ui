package org.zamedev.ui.res;

import org.zamedev.ui.Context;
import org.zamedev.ui.errors.UiError;
import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.graphics.FontExt;
import org.zamedev.ui.i18n.LocaleRules;
import org.zamedev.ui.i18n.LocaleTools;
import org.zamedev.ui.i18n.Quantity;
import org.zamedev.ui.view.LayoutParams;
import org.zamedev.ui.view.View;

class ResourceManager {
    private var context : Context;
    private var colorMap : Map<Int, Int>;
    private var dimenMap : Map<Int, Dimension>;
    private var stringMap : Map<Int, String>;
    private var pluralMap : Map<Int, Plural>;
    private var fontMap : Map<Int, FontExt>;
    private var drawableMap : Map<Int, Drawable>;
    private var styleMap : Map<Int, Style>;
    private var layoutMap : Map<Int, LayoutParams -> ResourceManager -> View>;
    private var boolMap : Map<Int, Bool>;
    private var intMap : Map<Int, Int>;
    private var floatMap : Map<Int, Float>;
    private var localeRules : LocaleRules;

    public function new(context : Context) {
        this.context = context;
        reload();
    }

    public function reload() {
        colorMap = new Map<Int, Int>();
        dimenMap = new Map<Int, Dimension>();
        stringMap = new Map<Int, String>();
        pluralMap = new Map<Int, Plural>();
        fontMap = new Map<Int, FontExt>();
        drawableMap = new Map<Int, Drawable>();
        styleMap = new Map<Int, Style>();
        layoutMap = new Map<Int, LayoutParams -> ResourceManager -> View>();
        boolMap = new Map<Int, Bool>();
        intMap = new Map<Int, Int>();
        floatMap = new Map<Int, Float>();

        localeRules = null;
        R._loadInto(this, context.configuration);
    }

    public function findIdByName(resName : String) : Null<Int> {
        return R.nameToIdMap[resName];
    }

    public function findNameById(resId : Int) : String {
        for (k in R.nameToIdMap.keys()) {
            if (R.nameToIdMap[k] == resId) {
                return k;
            }
        }

        return null;
    }

    public function getColor(resId : Int) : Int {
        return ensureFound(colorMap[resId], resId, "color");
    }

    public function getDimension(resId : Int) : Dimension {
        return ensureFound(dimenMap[resId], resId, "dimen", "dimension");
    }

    public function getFloat(resId : Int) : Float {
        var value = ensureFound(dimenMap[resId], resId, "dimen", "dimension");

        switch (value) {
            case EXACT(size):
                return size;

            default:
                throw new UiError('Only exact dimensions coul\'d be resolved as float for resource ${resId}');
        }
    }

    public function getDrawable(resId : Int) : Drawable {
        return ensureFound(drawableMap[resId], resId, "drawable");
    }

    public function getFont(resId : Int) : FontExt {
        return ensureFound(fontMap[resId], resId, "font");
    }

    public function getString(resId : Int) : String {
        return ensureFound(stringMap[resId], resId, "string");
    }

    public function getQuantityString(resId : Int, quantity : Float) : String {
        var plural = ensureFound(pluralMap[resId], resId, "plurals");

        if (localeRules == null) {
            localeRules = LocaleTools.rulesForLocale(plural.locale);
        }

        var result = plural.valueMap[localeRules.getQuantityForFloat(quantity)];

        if (result == null) {
            result = plural.valueMap[Quantity.OTHER];
        }

        if (result != null) {
            return result;
        }

        throw new UiError('Plural "${getResDisplayName(resId)}" was not found for quantity="${quantity}" and locale="${plural.locale}"');
    }

    public function getStyle(resId : Int) : Style {
        return ensureFound(styleMap[resId], resId, "style");
    }

    public function getBool(resId : Int) : Bool {
        return ensureFound(boolMap[resId], resId, "bool");
    }

    public function getInt(resId : Int) : Int {
        return ensureFound(intMap[resId], resId, "int");
    }

    public function getFloat(resId : Int) : Float {
        return ensureFound(floatMap[resId], resId, "float");
    }

    private function _getInflateFunc(resId : Int) : LayoutParams -> ResourceManager -> View {
        return ensureFound(layoutMap[resId], resId, "layout");
    }

    private function ensureFound<T>(value : T, resId : Int, refType : String, ?displayType : String) : T {
        if (value != null) {
            return value;
        }

        if (displayType == null) {
            displayType = refType;
        }

        throw new UiError('Resource "${getResDisplayName(resId)}" of type "${displayType}" was not found');
    }

    private function getResDisplayName(resId : Int) : String {
        for (name in R.nameToIdMap.keys()) {
            if (R.nameToIdMap[name] == resId) {
                return '@${name}';
            }
        }

        return '#${resId}';
    }
}
