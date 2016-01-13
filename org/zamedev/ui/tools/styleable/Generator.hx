package org.zamedev.ui.tools.styleable;

import haxe.io.Path;
import sys.io.File;

class Generator {
    macro private static function resolveThisPath() {
        return macro $v{ haxe.macro.Context.resolvePath("org/zamedev/ui/tools/styleable/Generator.hx") };
    }

    private static function resolveResDir() : String {
        return Path.directory(resolveThisPath()) + "/../../res";
    }

    public static function main() {
        var sbRegular = new StringBuf();
        var sbLayout = new StringBuf();
        var sbMapRegular = new StringBuf();
        var sbMapLayout = new StringBuf();

        var idRegular = 0;
        var idLayout = 1000000000;

        var map = StyleableMap.getNameToTypeMap();

        for (name in map.keys()) {
            if (name.substr(0, 7) == "layout_") {
                idLayout++;
                sbLayout.add('    var ${name} = ${idLayout}; // ${Std.string(map[name])}\n');
                sbMapLayout.add('        m[Styleable.${name}] = "${name}";\n');
            } else {
                idRegular++;
                sbRegular.add('    var ${name} = ${idRegular}; // ${Std.string(map[name])}\n');
                sbMapRegular.add('        m[Styleable.${name}] = "${name}";\n');
            }
        }

        var sb = new StringBuf();

        sb.add("package org.zamedev.ui.res;\n\n");
        sb.add("// This file is generated automatically\n\n");
        sb.add("@:enum\n");
        sb.add("abstract Styleable(Int) from Int to Int {\n");
        sb.add(sbRegular.toString());
        sb.add("\n    var _custom = 500000000;\n");
        sb.add("    var _layout = 1000000000;\n\n");
        sb.add(sbLayout.toString());
        sb.add("\n    var _customLayout = 1500000000;\n");
        sb.add("}\n");

        File.saveContent(resolveResDir() + "/Styleable.hx" , sb.toString());

        var sb = new StringBuf();

        sb.add("package org.zamedev.ui.res;\n\n");
        sb.add("// This file is generated automatically\n\n");
        sb.add("class StyleableNameMap {\n");
        sb.add("    private static var _idToNameMap : Map<Int, String> = null;\n\n");
        sb.add("    public static function getIdToNameMap() : Map<Int, String> {\n");
        sb.add("        if (_idToNameMap != null) {\n");
        sb.add("            return _idToNameMap;\n");
        sb.add("        }\n\n");
        sb.add("        var m = new Map<Int, String>();\n\n");
        sb.add(sbMapRegular.toString());
        sb.add("\n");
        sb.add(sbMapLayout.toString());
        sb.add("\n        _idToNameMap = m;\n");
        sb.add("        return _idToNameMap;\n");
        sb.add("    }\n");
        sb.add("}\n");

        File.saveContent(resolveResDir() + "/StyleableNameMap.hx", sb.toString());
    }
}
