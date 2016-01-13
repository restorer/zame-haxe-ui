package org.zamedev.ui.tools.generator;

import org.zamedev.lib.ds.LinkedMap;
import org.zamedev.ui.errors.UiParseError;
import org.zamedev.ui.res.Styleable;
import org.zamedev.ui.tools.ResGenerator;
import org.zamedev.ui.tools.parser.ParseHelper;
import org.zamedev.ui.tools.styleable.StyleableMap;

using Lambda;
using StringTools;
using org.zamedev.lib.LambdaExt;

class LayoutGenerator {
    private var genLayoutViewId : Int;

    private var resGenerator : ResGenerator;
    private var layoutMap : LinkedMap<String, GenItem<Xml>>;
    private var layoutPartMap : LinkedMap<String, GenItem<Xml>>;

    public function new(resGenerator : ResGenerator) {
        this.resGenerator = resGenerator;
        this.layoutMap = resGenerator.layoutMap;
        this.layoutPartMap = resGenerator.layoutPartMap;
    }

    public function generate(sb : StringBuf) : Void {
        for (key in layoutMap.keys()) {
            for (genItemValue in layoutMap[key].map) {
                var pos = genItemValue.pos;
                generateInflateLayout(sb, key, genItemValue.value, pos.configuration.toArray().join("_"), pos);
            }
        }
    }

    private function validateClassName(name : String, pos : GenPosition) : String {
        if (!~/^[A-Za-z][0-9A-Za-z_.]*$/.match(HaxeCode.validateIdentifier(name, pos))) {
            throw new UiParseError('${resGenerator.getDisplayName(name, pos)} is not valid class name', pos);
        }

        return name;
    }

    private function validateAttributeName(name : String, pos : GenPosition) : String {
        if (!~/^[A-Za-z][0-9A-Za-z_]*$/.match(HaxeCode.validateIdentifier(name, pos))) {
            throw new UiParseError('${resGenerator.getDisplayName(name, pos)} is not valid attribute name', pos);
        }

        return name;
    }

    private function generateInflateLayout(
        sb : StringBuf,
        layoutName : String,
        node : Xml,
        prefix : String,
        pos : GenPosition
    ) : Void {
        sb.add('\n\tprivate static function _inflateLayout_${prefix}_${layoutName}(l : LayoutParams, r : ResourceManager) : View {\n');
        genLayoutViewId = 1;

        generateInflateLayoutNode(
            sb,
            layoutName,
            node,
            "(l == null ? new LayoutParams() : l)",
            new Map<String, Bool>(),
            new Map<String, String>(),
            new Map<String, String>(),
            pos
        );

        sb.add("\t\treturn v1;\n");
        sb.add("\t}\n");
    }

    private function generateInflateLayoutNode(
        sb : StringBuf,
        layoutName : String,
        node : Xml,
        layoutParamsHaxeCode : String,
        visitedMap : Map<String, Bool>,
        vars : Map<String, String>,
        overrides : Map<String, String>,
        pos : GenPosition
    ) : Void {
        visitedMap[layoutName] = true;
        var className = node.nodeName;

        if (className == "include") {
            var includeResId = node.get("layout");

            if (includeResId == null) {
                throw new UiParseError('Missing layout reference in include tag', pos);
            }

            var refInfo = ParseHelper.parseRef(includeResId);

            if (refInfo == null || refInfo.type != "layout") {
                throw new UiParseError('Invalid layout reference "${includeResId}" in include tag', pos);
            }

            if (visitedMap.exists(refInfo.name)) {
                throw new UiParseError('Circular dependency on "${includeResId}"', pos);
            }

            var incLayoutItem = layoutMap[refInfo.name];

            if (incLayoutItem == null) {
                incLayoutItem = layoutPartMap[refInfo.name];
            }

            if (incLayoutItem == null) {
                throw new UiParseError('Included layout "${includeResId}" was not found', pos);
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
                            'Variable "${node.get(att)}" was not found for attribute "${att}" in included layout "${includeResId}"',
                            pos
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
                resGenerator.findQualifiedValue(incLayoutItem.map, pos),
                layoutParamsHaxeCode,
                newVisitedMap,
                newVars,
                newOverrides,
                pos
            );

            return;
        }

        var varName = 'v${genLayoutViewId}';
        validateClassName(className, pos);

        if (resGenerator.classMap.exists(className)) {
            resGenerator.includeMap[resGenerator.classMap[className]] = true;
        }

        sb.add('\t\tvar ${varName} = new ${className}(r.context);\n');
        sb.add('\t\t${varName}.onInflateStarted();\n');
        sb.add('\t\t${varName}.layoutParams = ${layoutParamsHaxeCode};\n');

        var styleResId = (overrides.exists("style") ? overrides["style"] : node.get("style"));

        if (styleResId != null) {
            var refInfo = ParseHelper.parseRef(styleResId);

            if (refInfo == null || refInfo.type != "style") {
                throw new UiParseError('Invalid style reference (${styleResId})', pos);
            }

            sb.add('\t\t${varName}.inflate(Styleable.style, r.styleMap[style.${resGenerator.validateResourceName(refInfo.name, pos)}]);\n');
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
                    throw new UiParseError('Variable "${node.get(att)}" was not found for attribute "${att}" for "${className}"', pos);
                }
            }

            if (att.substr(0, 7) == "layout_") {
                layoutAttMap[validateAttributeName(att, pos)] = value;
            } else {
                viewAttMap[validateAttributeName(att, pos)] = value;
            }
        }

        for (att in overrides.keys()) {
            if (att != "style") {
                if (att.substr(0, 7) == "layout_") {
                    layoutAttMap[validateAttributeName(att, pos)] = overrides[att];
                } else {
                    viewAttMap[validateAttributeName(att, pos)] = overrides[att];
                }
            }
        }

        for (att in layoutAttMap.keys()) {
            var type = StyleableMap.getTypeByName(att, pos);
            sb.add('\t\t${varName}.inflate(${HaxeCode.genStyleable(att)}, ${HaxeCode.genResolvedValue(layoutAttMap[att], type, pos)});\n');
        }

        for (att in viewAttMap.keys()) {
            var type = StyleableMap.getTypeByName(att, pos);
            sb.add('\t\t${varName}.inflate(${HaxeCode.genStyleable(att)}, ${HaxeCode.genResolvedValue(viewAttMap[att], type, pos)});\n');
        }

        var childViewId = 0;

        for (innerNode in node.elements()) {
            childViewId = ++genLayoutViewId;
            sb.add("\n");

            generateInflateLayoutNode(
                sb,
                layoutName,
                innerNode,
                '${varName}.createLayoutParams()',
                visitedMap,
                vars,
                new Map<String, String>(),
                pos
            );

            sb.add('\t\t${varName}.addChild(v${childViewId}, false);\n');
        }

        if (childViewId != 0) {
            sb.add("\n");
        }

        sb.add('\t\t${varName}.onInflateFinished();\n');
    }
}
