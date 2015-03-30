package org.zamedev.ui.tools.styleable;

import sys.io.File;

class Generator {
    macro private static function resolveStyleablePath() {
        return macro $v{ haxe.macro.Context.resolvePath("org/zamedev/ui/res/Styleable.hx") };
    }

    public static function main() {
        var sbRegular = new StringBuf();
        var sbLayout = new StringBuf();

        var idRegular = 0;
        var idLayout = 1000000000;

        var map = StyleableMap.getNameToTypeMap();

        for (name in map.keys()) {
            if (name.substr(0, 7) == "layout_") {
                idLayout++;
                sbLayout.add('    var ${name} = ${idLayout}; // ${Std.string(map[name])}\n');
            } else {
                idRegular++;
                sbRegular.add('    var ${name} = ${idRegular}; // ${Std.string(map[name])}\n');
            }
        }

        var sb = new StringBuf();

        sb.add("package org.zamedev.ui.res;\n\n");
        sb.add("@:enum\n");
        sb.add("abstract Styleable(Int) {\n");
        sb.add(sbRegular.toString());
        sb.add("\n    var _custom = 500000000;\n");
        sb.add("    var _layout = 1000000000;\n\n");
        sb.add(sbLayout.toString());
        sb.add("\n    var _customLayout = 1500000000;\n");
        sb.add("}\n");

        File.saveContent(resolveStyleablePath(), sb.toString());
    }
}
