package org.zamedev.ui.tools.generator;

import org.zamedev.lib.ds.LinkedMap;
import org.zamedev.ui.tools.ResGenerator;
import org.zamedev.ui.tools.styleable.StyleableMap;

using Lambda;
using StringTools;
using org.zamedev.lib.LambdaExt;

class StyleGenerator {
    private var styleMap : LinkedMap<String, GenItem<GenStyle>>;

    public function new(resGenerator : ResGenerator) {
        this.styleMap = resGenerator.styleMap;
    }

    public function generate(sb : StringBuf) : Void {
        for (key in styleMap.keys()) {
            for (genItemValue in styleMap[key].map) {
                var value = genItemValue.value;
                var pos = genItemValue.pos;

                if (!value.staticMap.empty()) {
                    generateStaticStyle(sb, key, value.staticMap, pos.configuration.toArray().join("_"), pos);
                }

                if (!value.runtimeMap.empty()) {
                    generateRuntimeStyle(sb, key, value.runtimeMap, pos.configuration.toArray().join("_"), pos);
                }
            }
        }
    }

    private function generateStaticStyle(
        sb : StringBuf,
        styleName : String,
        staticMap : Map<String, String>,
        prefix : String,
        pos : GenPosition
    ) : Void {
        sb.add('\n\tprivate static function _staticStyle_${prefix}_${styleName}(v : View, r : ResourceManager) : Void {\n');

        for (name in staticMap.keys()) {
            var type = StyleableMap.getTypeByName(name, pos);
            sb.add('\t\tv.inflate(${HaxeCode.genStyleable(name)}, ${HaxeCode.genResolvedValue(staticMap[name], type, pos)});\n');
        }

        sb.add("\t}\n");
    }

    private function generateRuntimeStyle(
        sb : StringBuf,
        styleName : String,
        runtimeMap : Map<String, Array<GenStyleRuntimeItem>>,
        prefix : String,
        pos : GenPosition
    ) : Void {
        var isFirstItem = true;
        sb.add('\n\tprivate static function _runtimeStyle_${prefix}_${styleName}(v : View, s : Map<String, Bool>, r : ResourceManager) : Void {\n');

        for (name in runtimeMap.keys()) {
            var type = StyleableMap.getTypeByName(name, pos);
            var itemList = runtimeMap[name];

            if (itemList.length == 0) {
                continue;
            }

            if (!isFirstItem) {
                sb.add("\n");
            }

            var isFirst = true;

            for (item in itemList) {
                var itemKeys = item.stateMap.keys().array();
                sb.add("\t\t");

                if (itemKeys.length != 0) {
                    sb.add(isFirst ? "if (" : "} else if (");
                    var sep = false;

                    for (key in itemKeys) {
                        if (sep) {
                            sb.add(" && ");
                        }

                        if (!item.stateMap[key]) {
                            sb.add("!");
                        }

                        sb.add('s[${HaxeCode.genString(key)}]');
                        sep = true;
                    }

                    sb.add(") {\n\t");
                } else if (!isFirst) {
                    sb.add("} else {\n\t");
                }

                sb.add('\t\tv.inflate(${HaxeCode.genStyleable(name)}, ${HaxeCode.genResolvedValue(item.value, type, pos)});\n');

                if (itemKeys.length == 0) {
                    break;
                }

                isFirst = false;
            }

            if (!isFirst) {
                sb.add("\t\t}\n");
            }

            isFirstItem = false;
        }

        sb.add("\t}\n");
    }
}
