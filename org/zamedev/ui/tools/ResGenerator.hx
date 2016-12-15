package org.zamedev.ui.tools;

import org.zamedev.lib.ds.LinkedMap;
import org.zamedev.ui.errors.UiParseError;
import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.DimensionType;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.graphics.DrawableType;
import org.zamedev.ui.graphics.GravityType;
import org.zamedev.ui.res.Configuration;
import org.zamedev.ui.res.Styleable;
import org.zamedev.ui.tools.generator.GenFont;
import org.zamedev.ui.tools.generator.GenItem;
import org.zamedev.ui.tools.generator.GenItemValue;
import org.zamedev.ui.tools.generator.GenPlural;
import org.zamedev.ui.tools.generator.GenPosition;
import org.zamedev.ui.tools.generator.GenStyle;
import org.zamedev.ui.tools.generator.HaxeCode;
import org.zamedev.ui.tools.generator.LayoutGenerator;
import org.zamedev.ui.tools.generator.StyleGenerator;
import org.zamedev.ui.tools.parser.ConfigurationHelper;

using Lambda;
using StringTools;
using org.zamedev.lib.LambdaExt;

class ResGenerator {
    private var resId : Int = 0;
    private var nameToIdMap : LinkedMap<String, Int> = new LinkedMap<String, Int>();

    public var includeMap : Map<String, Bool>;
    public var identifierMap : LinkedMap<String, GenItem<Nothing>> = new LinkedMap<String, GenItem<Nothing>>();
    public var colorMap : LinkedMap<String, GenItem<Int>> = new LinkedMap<String, GenItem<Int>>();
    public var dimenMap : LinkedMap<String, GenItem<Dimension>> = new LinkedMap<String, GenItem<Dimension>>();
    public var stringMap : LinkedMap<String, GenItem<String>> = new LinkedMap<String, GenItem<String>>();
    public var pluralMap : LinkedMap<String, GenItem<GenPlural>> = new LinkedMap<String, GenItem<GenPlural>>();
    public var fontMap : LinkedMap<String, GenItem<GenFont>> = new LinkedMap<String, GenItem<GenFont>>();
    public var drawableMap : LinkedMap<String, GenItem<Drawable>> = new LinkedMap<String, GenItem<Drawable>>();
    public var styleMap : LinkedMap<String, GenItem<GenStyle>> = new LinkedMap<String, GenItem<GenStyle>>();
    public var layoutMap : LinkedMap<String, GenItem<Xml>> = new LinkedMap<String, GenItem<Xml>>();
    public var layoutPartMap : LinkedMap<String, GenItem<Xml>> = new LinkedMap<String, GenItem<Xml>>();
    public var boolMap : LinkedMap<String, GenItem<Bool>> = new LinkedMap<String, GenItem<Bool>>();
    public var intMap : LinkedMap<String, GenItem<Int>> = new LinkedMap<String, GenItem<Int>>();
    public var floatMap : LinkedMap<String, GenItem<Float>> = new LinkedMap<String, GenItem<Float>>();

    public var classMap : Map<String, String> = [
        "ImageView" => "org.zamedev.ui.view.ImageView",
        "Rect" => "org.zamedev.ui.view.Rect",
        "SpaceView" => "org.zamedev.ui.view.SpaceView",
        "TextView" => "org.zamedev.ui.view.TextView",
        "View" => "org.zamedev.ui.view.View",
        "AbsoluteLayout" => "org.zamedev.ui.widget.AbsoluteLayout",
        "Button" => "org.zamedev.ui.widget.Button",
        "FrameLayout" => "org.zamedev.ui.widget.FrameLayout",
        "FullStageFrameLayout" => "org.zamedev.ui.widget.FullStageFrameLayout",
        "LinearLayout" => "org.zamedev.ui.widget.LinearLayout",
        "Progress" => "org.zamedev.ui.widget.Progress",
        "Radio" => "org.zamedev.ui.widget.Radio",
        "RecyclerView" => "org.zamedev.ui.widget.RecyclerView",
        "Toggle" => "org.zamedev.ui.widget.Toggle",
        "EditText" => "org.zamedev.ui.widget.EditText",
    ];

    public function new() {
    }

    public function putIdentifier(name : String, pos : GenPosition) : Void {
        putToMap("id", identifierMap, name, null, pos);
    }

    public function putColor(name : String, value : Int, pos : GenPosition) : Void {
        putIfNotExists("color", colorMap, name, value, pos);
    }

    public function putDimension(name : String, value : Dimension, pos : GenPosition) : Void {
        putIfNotExists("dimen", dimenMap, name, value, pos);
    }

    public function putString(name : String, value : String, pos : GenPosition) : Void {
        putIfNotExists("string", stringMap, name, value, pos);
    }

    public function putPlural(name : String, value : GenPlural, pos : GenPosition) : Void {
        putIfNotExists("plurals", pluralMap, name, value, pos);
    }

    public function putFont(name : String, value : GenFont, pos : GenPosition) : Void {
        putIfNotExists("font", fontMap, name, value, pos);
    }

    public function putDrawable(name : String, value : Drawable, pos : GenPosition) : Void {
        putIfNotExists("drawable", drawableMap, name, value, pos);
    }

    public function putStyle(name : String, value : GenStyle, pos : GenPosition) : Void {
        putIfNotExists("style", styleMap, name, value, pos);
    }

    public function putLayout(name : String, value : Xml, pos : GenPosition) : Void {
        putIfNotExists("layout", layoutMap, name, value, pos);
    }

    public function putLayoutPart(name : String, value : Xml, pos : GenPosition) : Void {
        putIfNotExists("layoutpart", layoutPartMap, name, value, pos);
    }

    public function putBool(name : String, value : Bool, pos : GenPosition) : Void {
        putIfNotExists("bool", boolMap, name, value, pos);
    }

    public function putInt(name : String, value : Int, pos : GenPosition) : Void {
        putIfNotExists("int", intMap, name, value, pos);
    }

    public function putFloat(name : String, value : Float, pos : GenPosition) : Void {
        putIfNotExists("float", floatMap, name, value, pos);
    }

    public function getPackedDrawable(name : String, pos : GenPosition) : Drawable {
        var item = drawableMap[validateResourceName(name, pos)];

        if (item == null) {
            return null;
        }

        var result = findQualifiedValue(item.map, pos);

        if (result == null) {
            throw new UiParseError('${getDisplayName(name, pos)} - packed drawable not found', pos);
        }

        if (result.type != DrawableType.ASSET_BITMAP) {
            throw new UiParseError('${getDisplayName(name, pos)} - packed drawable must have bitmap type', pos);
        }

        return result;
    }

    public function validateResourceName(name : String, pos : GenPosition) : String {
        if (!~/^[A-Za-z_][0-9A-Za-z_]*$/.match(HaxeCode.validateIdentifier(name, pos))) {
            throw new UiParseError('${getDisplayName(name, pos)} is not valid resource identifier', pos);
        }

        return name;
    }

    public function getDisplayName(name : String, pos : GenPosition) : String {
        if (pos.configuration.isEmpty()) {
            return '"${name}"';
        } else {
            return '"${name}" (for "${pos.configuration.toQualifierString()}")';
        }
    }

    public function findQualifiedValue<T>(map : Map<String, GenItemValue<T>>, pos : GenPosition) : T {
        for (key in ConfigurationHelper.computeQualifierKeys(pos.configuration)) {
            if (map.exists(key)) {
                return map[key].value;
            }
        }

        throw new UiParseError("Internal error", pos);
    }

    public function generate() : String {
        includeMap = [
            "org.zamedev.ui.graphics.Dimension" => true,
            "org.zamedev.ui.graphics.DimensionType" => true,
            "org.zamedev.ui.graphics.Drawable" => true,
            "org.zamedev.ui.graphics.DrawableType" => true,
            "org.zamedev.ui.graphics.FontExt" => true,
            "org.zamedev.ui.graphics.GravityType" => true,
            "org.zamedev.ui.graphics.TextAlignExt" => true,
            "org.zamedev.ui.i18n.Quantity" => true,
            "org.zamedev.ui.res.Configuration" => true,
            "org.zamedev.ui.res.ResourceManager" => true,
            "org.zamedev.ui.res.Style" => true,
            "org.zamedev.ui.res.Styleable" => true,
            "org.zamedev.ui.view.LayoutParams" => true,
            "org.zamedev.ui.view.View" => true,
            "org.zamedev.ui.view.ViewVisibility" => true,
            "org.zamedev.ui.widget.LinearLayoutOrientation" => true,
        ];

        var sb = new StringBuf();
        sb.add("\n@:access(org.zamedev.ui.res.ResourceManager)\n");
        sb.add("class R {\n");

        generateNameToIdMap(sb);

        generateIds(sb, "id", identifierMap);
        generateIds(sb, "color", colorMap);
        generateIds(sb, "dimen", dimenMap);
        generateIds(sb, "string", stringMap);
        generateIds(sb, "plurals", pluralMap);
        generateIds(sb, "font", fontMap);
        generateIds(sb, "drawable", drawableMap);
        generateIds(sb, "style", styleMap);
        generateIds(sb, "layout", layoutMap);
        generateIds(sb, "bool", boolMap);
        generateIds(sb, "int", intMap);
        generateIds(sb, "float", floatMap);

        sb.add("\tpublic static function _loadInto(r : ResourceManager, c : Configuration) : Void {");

        generateLoadValues(sb, colorMap, function(key : String, value : Int, pos : GenPosition) : String {
            return 'r.colorMap[color.${key}] = ${HaxeCode.genColor(value)};';
        });

        generateLoadValues(sb, dimenMap, function(key : String, value : Dimension, pos : GenPosition) : String {
            return 'r.dimenMap[dimen.${key}] = ${HaxeCode.genDimension(value)};';
        });

        generateLoadValues(sb, stringMap, function(key : String, value : String, pos : GenPosition) : String {
            return 'r.stringMap[string.${key}] = ${HaxeCode.genString(value)};';
        });

        generateLoadValues(sb, pluralMap, function(key : String, value : GenPlural, pos : GenPosition) : String {
            var result = 'r.pluralMap[plurals.${key}] = { locale : ${HaxeCode.genString(pos.configuration.locale)}, valueMap : [';
            var sep = false;

            for (quantity in value.keys()) {
                if (sep) {
                    result += ',';
                }

                result += ' ${HaxeCode.genQuantity(quantity)} => ${HaxeCode.genString(value[quantity])}';
                sep = true;
            }

            return result + ' ] };';
        });

        generateLoadValues(sb, fontMap, function(key : String, value : GenFont, pos : GenPosition) : String {
            return 'r.fontMap[font.${key}] = ${HaxeCode.genFont(value)};';
        });

        generateLoadValues(sb, drawableMap, function(key : String, value : Drawable, pos : GenPosition) : String {
            return 'r.drawableMap[drawable.${key}] = ${HaxeCode.genDrawable(value, pos)};';
        });

        generateLoadValues(sb, styleMap, function(key : String, value : GenStyle, pos : GenPosition) : String {
            var prefix = pos.configuration.toArray().join("_");
            var staticPart = value.staticMap.empty() ? "null" : '_staticStyle_${prefix}_${key}';
            var runtimePart = value.runtimeMap.empty() ? "null" : '_runtimeStyle_${prefix}_${key}';
            return 'r.styleMap[style.${key}] = { staticFunc : ${staticPart}, runtimeFunc : ${runtimePart} };';
        });

        generateLoadValues(sb, layoutMap, function(key : String, value : Xml, pos : GenPosition) : String {
            return 'r.layoutMap[layout.${key}] = _inflateLayout_${pos.configuration.toArray().join("_")}_${key};';
        });

        generateLoadValues(sb, boolMap, function(key : String, value : Bool, pos : GenPosition) : String {
            return 'r.boolMap[bool.${key}] = ${HaxeCode.genBool(value)};';
        });

        generateLoadValues(sb, intMap, function(key : String, value : Int, pos : GenPosition) : String {
            return 'r.intMap[int.${key}] = ${HaxeCode.genInt(value)};';
        });

        generateLoadValues(sb, floatMap, function(key : String, value : Float, pos : GenPosition) : String {
            return 'r.floatMap[float.${key}] = ${HaxeCode.genFloat(value)};';
        });

        sb.add("\t}\n");

        var styleGenerator = new StyleGenerator(this);
        styleGenerator.generate(sb);

        var layoutGenerator = new LayoutGenerator(this);
        layoutGenerator.generate(sb);

        sb.add("}\n");

        var importList = includeMap.keys().array();
        importList.sort(Reflect.compare);

        var sbPrepend = new StringBuf();
        sbPrepend.add("package ;\n\n");

        for (name in importList) {
            sbPrepend.add('import ${name};\n');
        }

        var codeString = sb.toString();

        while (true) {
            var newCodeString = codeString.replace("\n\n\n", "\n\n");

            if (codeString == newCodeString) {
                break;
            }

            codeString = newCodeString;
        }

        return (sbPrepend.toString() + codeString).replace("\t", "    ");
    }

    private function putToMap<T>(
        resType : String,
        map : LinkedMap<String, GenItem<T>>,
        name : String,
        value : T,
        pos : GenPosition
    ) : Bool {
        name = validateResourceName(name, pos);
        var qKey = pos.configuration.toQualifierString();

        if (!map.exists(name)) {
            resId++;
            nameToIdMap['${resType}/${name}'] = resId;

            map[name] = {
                id : resId,
                map : new Map<String, GenItemValue<T>>(),
            };
        } else if (map[name].map.exists(qKey)) {
            return false;
        }

        map[name].map[qKey] = {
            value : value,
            pos : pos,
        };

        return true;
    }

    private function putIfNotExists<T>(
        resType : String,
        map : LinkedMap<String, GenItem<T>>,
        name : String,
        value : T,
        pos : GenPosition
    ) : Void {
        if (!putToMap(resType, map, name, value, pos)) {
            throw new UiParseError('Duplicate resource ${getDisplayName(name, pos)} of type "${resType}"', pos);
        }
    }

    private function generateNameToIdMap(sb : StringBuf) : Void {
        sb.add('\tpublic static var nameToIdMap : Map<String, Int> = [\n');

        for (key in nameToIdMap.keys()) {
            sb.add('\t\t${HaxeCode.genString(key)} => ${HaxeCode.genInt(nameToIdMap[key])},\n');
        }

        sb.add("\t];\n\n");
    }

    private function generateIds<T>(sb : StringBuf, name : String, map : LinkedMap<String, GenItem<T>>) : Void {
        sb.add('\tpublic static var ${name} = {\n');

        for (key in map.keys()) {
            sb.add('\t\t${key}: ${map[key].id},\n');
        }

        sb.add("\t};\n\n");
    }

    // https://developer.android.com/guide/topics/resources/providing-resources.html#BestMatch
    private function generateLoadValues<T>(
        sb : StringBuf,
        map : LinkedMap<String, GenItem<T>>,
        func : String -> T -> GenPosition -> String
    ) : Void {
        sb.add("\n");

        for (resKey in map.keys()) {
            var genItem = map[resKey];

            var posList = genItem.map.map(function(v : GenItemValue<T>) : GenPosition {
                return v.pos;
            }).array();

            if (posList.length == 0) {
                throw new UiParseError('Internal error while generating R.hx (empty configuration list)');
                continue;
            }

            if (posList.length == 1 && posList[0].configuration.isEmpty()) {
                var genItemValue = genItem.map[""];

                sb.add("\t\t");
                sb.add(func(resKey, genItemValue.value, genItemValue.pos));
                sb.add("\n");
                continue;
            }

            posList.sort(function(a : GenPosition, b : GenPosition) : Int {
                return - a.configuration.compareTo(b.configuration);
            });

            var isFirst = true;
            sb.add("\n");

            for (pos in posList) {
                sb.add("\t\t");

                if (!pos.configuration.isEmpty()) {
                    sb.add(isFirst ? "if (" : "} else if (");

                    var sep = false;
                    var configMap = pos.configuration.toMap();

                    for (configKey in configMap.keys()) {
                        if (sep) {
                            sb.add(" && ");
                        }

                        sb.add('c.${configKey} == ${HaxeCode.genString(configMap[configKey])}');
                        sep = true;
                    }

                    sb.add(") {\n");
                } else if (isFirst) {
                    throw new UiParseError('Internal error while generating R.hx (incorrect sort by qualifiers)');
                } else {
                    sb.add("} else {\n");
                }

                var genItemValue = genItem.map[pos.configuration.toQualifierString()];

                sb.add("\t\t\t");
                sb.add(func(resKey, genItemValue.value, genItemValue.pos));
                sb.add("\n");

                isFirst = false;
            }

            sb.add("\t\t}\n\n");
        }
    }
}
