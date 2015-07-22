package org.zamedev.ui.tools;

import de.polygonal.Printf;
import org.zamedev.lib.ds.LinkedMap;
import org.zamedev.ui.errors.UiParseError;
import org.zamedev.ui.graphics.Color;
import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.DimensionTools;
import org.zamedev.ui.graphics.DimensionType;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.graphics.DrawableType;
import org.zamedev.ui.graphics.Gravity;
import org.zamedev.ui.graphics.GravityTools;
import org.zamedev.ui.graphics.GravityType;
import org.zamedev.ui.res.Styleable;
import org.zamedev.ui.tools.generator.GenFont;
import org.zamedev.ui.tools.generator.HaxeCode;
import org.zamedev.ui.tools.generator.GenItem;
import org.zamedev.ui.tools.generator.GenSelector;
import org.zamedev.ui.tools.generator.GenStyle;
import org.zamedev.ui.tools.styleable.StyleableMap;
import org.zamedev.ui.tools.styleable.StyleableType;
import org.zamedev.ui.tools.parser.ParseHelper;

using StringTools;
using org.zamedev.lib.LambdaExt;

class ResGenerator {
    private var resId:Int = 0;
    private var nameToIdMap:LinkedMap<String, Int> = new LinkedMap<String, Int>();
    private var colorMap:LinkedMap<String, GenItem<Int>> = new LinkedMap<String, GenItem<Int>>();
    private var dimenMap:LinkedMap<String, GenItem<Dimension>> = new LinkedMap<String, GenItem<Dimension>>();
    private var stringMap:LinkedMap<String, GenItem<String>> = new LinkedMap<String, GenItem<String>>();
    private var fontMap:LinkedMap<String, GenItem<GenFont>> = new LinkedMap<String, GenItem<GenFont>>();
    private var drawableMap:LinkedMap<String, GenItem<Drawable>> = new LinkedMap<String, GenItem<Drawable>>();
    private var styleMap:LinkedMap<String, GenItem<GenStyle>> = new LinkedMap<String, GenItem<GenStyle>>();
    private var selectorMap:LinkedMap<String, GenItem<GenSelector>> = new LinkedMap<String, GenItem<GenSelector>>();
    private var layoutMap:LinkedMap<String, GenItem<Xml>> = new LinkedMap<String, GenItem<Xml>>();
    private var layoutPartMap:LinkedMap<String, GenItem<Xml>> = new LinkedMap<String, GenItem<Xml>>();
    private var genLayoutViewId:Int;
    private var includeMap:Map<String, Bool>;

    private var classMap:Map<String, String> = [
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
    ];

    public function new():Void {
    }

    public function putColor(name:String, value:Int):Void {
        putIfNotExists("color", colorMap, name, value);
    }

    public function putDimen(name:String, value:Dimension):Void {
        putIfNotExists("dimen", dimenMap, name, value);
    }

    public function putString(name:String, value:String):Void {
        putIfNotExists("string", stringMap, name, value);
    }

    public function putFont(name:String, value:GenFont):Void {
        putIfNotExists("font", fontMap, name, value);
    }

    public function putDrawable(name:String, value:Drawable):Void {
        putIfNotExists("drawable", drawableMap, name, value);
    }

    public function putStyle(name:String, value:GenStyle):Void {
        putIfNotExists("style", styleMap, name, value);
    }

    public function putSelector(name:String, value:GenSelector):Void {
        putIfNotExists("selector", selectorMap, name, value);
    }

    public function putLayout(name:String, value:Xml):Void {
        if (layoutPartMap.exists(name)) {
            throw new UiParseError('duplicate resource "${name}" of type "layout" (in "layoutPart")');
        }

        putIfNotExists("layout", layoutMap, name, value);
    }

    public function putLayoutPart(name:String, value:Xml):Void {
        if (layoutMap.exists(name)) {
            throw new UiParseError('duplicate resource "${name}" of type "layoutPart" (in "layout")');
        }

        putIfNotExists("layoutPart", layoutPartMap, name, value);
    }

    public function getDrawable(name:String):Drawable {
        var item = drawableMap[validateResourceName(name)];
        return (item == null ? null : item.value);
    }

    public function generate():String {
        includeMap = [
            "org.zamedev.ui.graphics.Dimension" => true,
            "org.zamedev.ui.graphics.DimensionType" => true,
            "org.zamedev.ui.graphics.Drawable" => true,
            "org.zamedev.ui.graphics.DrawableType" => true,
            "org.zamedev.ui.graphics.FontExt" => true,
            "org.zamedev.ui.graphics.GravityType" => true,
            "org.zamedev.ui.graphics.TextAlignExt" => true,
            "org.zamedev.ui.res.ResourceManager" => true,
            "org.zamedev.ui.res.Selector" => true,
            "org.zamedev.ui.res.Style" => true,
            "org.zamedev.ui.res.Styleable" => true,
            "org.zamedev.ui.view.View" => true,
            "org.zamedev.ui.view.ViewVisibility" => true,
            "org.zamedev.ui.view.LayoutParams" => true,
            "org.zamedev.ui.widget.LinearLayoutOrientation" => true,
        ];

        var sb = new StringBuf();
        sb.add("\n@:access(org.zamedev.ui.res.ResourceManager)\n");
        sb.add("class R {\n");

        generateNameToIdMap(sb);
        generateIds(sb, "color", colorMap);
        generateIds(sb, "dimen", dimenMap);
        generateIds(sb, "string", stringMap);
        generateIds(sb, "font", fontMap);
        generateIds(sb, "drawable", drawableMap);
        generateIds(sb, "style", styleMap);
        generateIds(sb, "selector", selectorMap);
        generateIds(sb, "layout", layoutMap);

        sb.add("\tpublic static function _loadInto(r:ResourceManager, locale:String):Void {");

        generateLoadColor(sb);
        generateLoadDimen(sb);
        generateLoadString(sb);
        generateLoadFont(sb);
        generateLoadDrawable(sb);
        generateLoadStyle(sb);
        generateLoadSelector(sb);
        generateLoadLayout(sb);

        sb.add("\t}\n");

        for (key in layoutMap.keys()) {
            var item = layoutMap[key];
            generateInflateLayout(sb, key, item.value);
        }

        sb.add("}\n");

        var importList = includeMap.keys().array();
        importList.sort(Reflect.compare);

        var sbPrepend = new StringBuf();
        sbPrepend.add("package ;\n\n");

        for (name in importList) {
            sbPrepend.add('import ${name};\n');
        }

        return sbPrepend.toString() + sb.toString();
    }

    private function validateResourceName(name:String):String {
        if (!~/^[A-Za-z_][0-9A-Za-z_]*$/.match(HaxeCode.validateIdentifier(name))) {
            throw new UiParseError('"${name}" is invalid resource identifier');
        }

        return name;
    }

    private function validateClassName(name:String):String {
        if (!~/^[A-Za-z][0-9A-Za-z_.]*$/.match(HaxeCode.validateIdentifier(name))) {
            throw new UiParseError('"${name}" is invalid class name');
        }

        return name;
    }

    private function validateAttributeName(name:String):String {
        if (!~/^[A-Za-z][0-9A-Za-z_]*$/.match(HaxeCode.validateIdentifier(name))) {
            throw new UiParseError('"${name}" is invalid attribute name');
        }

        return name;
    }

    private function putIfNotExists<T>(resType:String, map:LinkedMap<String, GenItem<T>>, name:String, value:T):Void {
        if (map.exists(validateResourceName(name))) {
            throw new UiParseError('duplicate resource "${name}" of type "${resType}"');
        }

        resId++;
        nameToIdMap['${resType}/${name}'] = resId;

        map[name] = {
            id: resId,
            value: value,
        };
    }

    private function generateNameToIdMap(sb:StringBuf):Void {
        sb.add('\tpublic static var nameToIdMap:Map<String, Int> = [\n');

        for (key in nameToIdMap.keys()) {
            sb.add('\t\t${HaxeCode.genString(key)} => ${nameToIdMap[key]},\n');
        }

        sb.add("\t];\n\n");
    }

    private function generateIds<T>(sb:StringBuf, name:String, map:LinkedMap<String, GenItem<T>>):Void {
        sb.add('\tpublic static var ${name} = {\n');

        for (key in map.keys()) {
            sb.add('\t\t${key}: ${map[key].id},\n');
        }

        sb.add("\t};\n\n");
    }

    private function generateLoadColor(sb:StringBuf):Void {
        sb.add("\n");

        for (key in colorMap.keys()) {
            sb.add('\t\tr.colorMap[color.${key}] = ${HaxeCode.genColor(colorMap[key].value)};\n');
        }
    }

    private function generateLoadDimen(sb:StringBuf):Void {
        sb.add("\n");

        for (key in dimenMap.keys()) {
            sb.add('\t\tr.dimenMap[dimen.${key}] = ${HaxeCode.genDimension(dimenMap[key].value)};\n');
        }
    }

    private function generateLoadString(sb:StringBuf):Void {
        sb.add("\n");

        for (key in stringMap.keys()) {
            sb.add('\t\tr.stringMap[string.${key}] = ${HaxeCode.genString(stringMap[key].value)};\n');
        }
    }

    private function generateLoadFont(sb:StringBuf):Void {
        sb.add("\n");

        for (key in fontMap.keys()) {
            sb.add('\t\tr.fontMap[font.${key}] = ${HaxeCode.genFont(fontMap[key].value)};\n');
        }
    }

    private function generateLoadDrawable(sb:StringBuf):Void {
        sb.add("\n");

        for (key in drawableMap.keys()) {
            sb.add('\t\tr.drawableMap[drawable.${key}] = ${HaxeCode.genDrawable(drawableMap[key].value)};\n');
        }
    }

    private function generateLoadStyle(sb:StringBuf):Void {
        for (key in styleMap.keys()) {
            var genStyle = styleMap[key].value;
            sb.add('\n\t\tr.styleMap[style.${key}] = new Style([\n');

            for (name in genStyle.keys()) {
                var type = StyleableMap.getTypeByName(name);
                sb.add('\t\t\t${HaxeCode.genStyleable(name)} => ${HaxeCode.genResolvedValue(genStyle[name], type)},\n');
            }

            sb.add('\t\t]);\n');
        }
    }

    private function generateLoadSelector(sb:StringBuf):Void {
        for (key in selectorMap.keys()) {
            var genSelector = selectorMap[key].value;
            sb.add('\n\t\tr.selectorMap[selector.${key}] = new Selector([\n');

            for (name in genSelector.keys()) {
                var type = StyleableMap.getTypeByName(name);

                if (genSelector[name].length == 0) {
                    sb.add('\t\t\t${HaxeCode.genStyleable(name)} => [],\n');
                } else {
                    sb.add('\t\t\t${HaxeCode.genStyleable(name)} => [{\n');
                    var sep = false;

                    for (genSelectorItem in genSelector[name]) {
                        if (sep) {
                            sb.add("\t\t\t}, {\n");
                        } else {
                            sep = true;
                        }

                        if (Lambda.empty(genSelectorItem.stateMap)) {
                            sb.add("\t\t\t\tstateMap: new Map<String, Bool>(),\n");
                        } else {
                            sb.add("\t\t\t\tstateMap: [\n");

                            for (tag in genSelectorItem.stateMap.keys()) {
                                sb.add('\t\t\t\t\t${HaxeCode.genString(tag)} => ${HaxeCode.genBool(genSelectorItem.stateMap[tag])},\n');
                            }

                            sb.add("\t\t\t\t],\n");
                        }

                        sb.add('\t\t\t\tvalue: ${HaxeCode.genResolvedValue(genSelectorItem.value, type)},\n');
                    }

                    sb.add("\t\t\t}],\n");
                }
            }

            sb.add('\t\t]);\n');
        }
    }

    private function generateLoadLayout(sb:StringBuf):Void {
        sb.add("\n");

        for (key in layoutMap.keys()) {
            sb.add('\t\tr.layoutMap[layout.${key}] = _inflateLayout_${key};\n');
        }
    }

    private function generateInflateLayout(sb:StringBuf, layoutName:String, node:Xml):Void {
        sb.add('\n\tprivate static function _inflateLayout_${layoutName}(l:LayoutParams, r:ResourceManager):View {\n');
        genLayoutViewId = 1;

        generateInflateLayoutNode(
            sb,
            layoutName,
            node,
            "(l == null ? new LayoutParams() : l)",
            new Map<String, Bool>(),
            new Map<String, String>(),
            new Map<String, String>()
        );

        sb.add("\t\treturn v1;\n");
        sb.add("\t}\n");
    }

    private function generateInflateLayoutNode(
        sb:StringBuf,
        layoutName:String,
        node:Xml,
        layoutParamsHaxeCode:String,
        visitedMap:Map<String, Bool>,
        vars:Map<String, String>,
        overrides:Map<String, String>
    ):Void {
        visitedMap[layoutName] = true;
        var className = node.nodeName;

        if (className == "include") {
            var includeResId = node.get("layout");

            if (includeResId == null) {
                throw new UiParseError('@layout/${layoutName} - layout is not specified in include tag');
            }

            var refInfo = ParseHelper.parseRef(includeResId);

            if (refInfo == null || refInfo.type != "layout") {
                throw new UiParseError('@layout/${layoutName} - invalid layout reference in include tag (${includeResId})');
            }

            if (visitedMap.exists(refInfo.name)) {
                throw new UiParseError('@layout/${layoutName} - circular dependency on ${includeResId}');
            }

            var incLayoutItem = layoutMap[refInfo.name];

            if (incLayoutItem == null) {
                incLayoutItem = layoutPartMap[refInfo.name];
            }

            if (incLayoutItem == null) {
                throw new UiParseError('@layout/${layoutName} - included layout not found (${includeResId})');
            }

            var newVars = new Map<String, String>();
            var newOverrides = new Map<String, String>();

            for (att in node.attributes()) {
                if (att == "layout") {
                    continue;
                }

                var value = node.get(att);

                if (value.substr(0, 5) == "@var/") {
                    var value = vars[value.substr(5)];

                    if (value == null) {
                        throw new UiParseError(
                            '@layout/${layoutName} - ${node.get(att)} not found for attribute ${att} in include tag (${includeResId})'
                        );
                    }
                }

                if (att.substr(0, 4) == "var_") {
                    newVars[att.substr(4)] = value;
                } else {
                    newOverrides[att] = value;
                }
            }

            var newVisitedMap = new Map<String, Bool>();

            for (key in visitedMap.keys()) {
                newVisitedMap[key] = visitedMap[key];
            }

            sb.add("\n");

            generateInflateLayoutNode(
                sb,
                refInfo.name,
                incLayoutItem.value,
                layoutParamsHaxeCode,
                newVisitedMap,
                newVars,
                newOverrides
            );

            return;
        }

        var varName = 'v${genLayoutViewId}';
        validateClassName(className);

        if (classMap.exists(className)) {
            includeMap[classMap[className]] = true;
        }

        sb.add('\t\tvar ${varName} = new ${className}(r.context);\n');
        sb.add('\t\t${varName}.onInflateStarted();\n');
        sb.add('\t\t${varName}.layoutParams = ${layoutParamsHaxeCode};\n');

        var styleResId = (overrides.exists("style") ? overrides["style"] : node.get("style"));

        if (styleResId != null) {
            var refInfo = ParseHelper.parseRef(styleResId);

            if (refInfo == null || refInfo.type != "style") {
                throw new UiParseError('@layout/${layoutName} - invalid style reference (${styleResId})');
            }

            sb.add('\t\tr.styleMap[style.${validateResourceName(refInfo.name)}].apply(${varName});\n');
        }

        var layoutAttMap = new LinkedMap<String, String>();
        var viewAttMap = new LinkedMap<String, String>();

        for (att in node.attributes()) {
            if (att == "style" || overrides.exists(att)) {
                continue;
            }

            var value = node.get(att);

            if (value.substr(0, 5) == "@var/") {
                value = vars[value.substr(5)];

                if (value == null) {
                    throw new UiParseError('@layout/${layoutName} - class ${className}, ${node.get(att)} not found for attribute ${att}');
                }
            }

            if (att.substr(0, 7) == "layout_") {
                layoutAttMap[validateAttributeName(att)] = value;
            } else {
                viewAttMap[validateAttributeName(att)] = value;
            }
        }

        for (att in overrides.keys()) {
            if (att != "style") {
                if (att.substr(0, 7) == "layout_") {
                    layoutAttMap[validateAttributeName(att)] = overrides[att];
                } else {
                    viewAttMap[validateAttributeName(att)] = overrides[att];
                }
            }
        }

        for (att in layoutAttMap.keys()) {
            var type = StyleableMap.getTypeByName(att);
            sb.add('\t\t${varName}.inflate(Styleable.${att}, ${HaxeCode.genResolvedValue(layoutAttMap[att], type)});\n');
        }

        for (att in viewAttMap.keys()) {
            var type = StyleableMap.getTypeByName(att);
            sb.add('\t\t${varName}.inflate(Styleable.${att}, ${HaxeCode.genResolvedValue(viewAttMap[att], type)});\n');
        }

        var childViewId = 0;

        for (innerNode in node.elements()) {
            childViewId = ++genLayoutViewId;
            sb.add("\n");
            generateInflateLayoutNode(sb, layoutName, innerNode, '${varName}.createLayoutParams()', visitedMap, vars, new Map<String, String>());
            sb.add('\t\t${varName}.addChild(v${childViewId}, false);\n');
        }

        if (childViewId != 0) {
            sb.add("\n");
        }

        sb.add('\t\t${varName}.onInflateFinished();\n');
    }
}
