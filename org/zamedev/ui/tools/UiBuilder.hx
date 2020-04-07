package org.zamedev.ui.tools;

import haxe.io.Path;
import org.zamedev.ui.errors.UiParseError;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.res.Configuration;
import org.zamedev.ui.tools.generator.GenPosition;
import org.zamedev.ui.tools.parser.ConfigurationHelper;
import sys.FileSystem;
import sys.io.File;

class UiBuilder {
    private static var assetsPath : String;
    private static var resGenerator : ResGenerator;
    private static var resParser : ResParser;

    private static function processAssetItems(basePath : String, type : String, configuration : Configuration) : Void {
        for (name in FileSystem.readDirectory(basePath)) {
            var path = Path.join([basePath, name]);

            if (FileSystem.isDirectory(path)) {
                continue;
            }

            switch (Path.extension(name).toLowerCase()) {
                case "png" | "jpg" | "jpeg" | "bmp":
                    if (type != "drawable") {
                        throw new UiParseError(
                            "Drawable must be in \"drawable\" folder (maybe with qualifiers)",
                            new GenPosition(configuration, path)
                        );
                    }

                    resGenerator.putDrawable(
                        Path.withoutExtension(Path.withoutDirectory(path)),
                        Drawable.fromAssetBitmap(path.substr(assetsPath.length + 1)),
                        new GenPosition(configuration, path)
                    );

                case "xml":
                    resParser.parseResources(File.getContent(path), new GenPosition(configuration, path));
            }
        }
    }

    private static function processAssets(basePath : String) : Void {
        for (name in FileSystem.readDirectory(basePath)) {
            var path = Path.join([basePath, name]);

            if (!FileSystem.isDirectory(path)) {
                continue;
            }

            var qualifiers = name.split("-");
            var type = qualifiers.splice(0, 1)[0];

            if (type != 'drawable' && type != 'resource' && type != 'layout') {
                continue;
            }

            processAssetItems(path, type, ConfigurationHelper.parse(qualifiers, path));
        }
    }

    public static function main() {
        var rootPath = Sys.args()[0];
        var sourcePath = Path.join([rootPath, "source"]);

        assetsPath = Path.join([rootPath, "assets"]);

        resGenerator = new ResGenerator();
        resParser = new ResParser();

        println("Processing assets ...");
        processAssets(assetsPath);

        println("Process resources ...");
        resParser.toGenerator(resGenerator);

        println("Saving R.hx ...");
        FileSystem.createDirectory(sourcePath);
        File.saveContent(Path.join([sourcePath, "R.hx"]), resGenerator.generate());
    }

    private static function println(message : String) : Void {
        #if sys
            Sys.print(message + "\n");
        #elseif neko
            neko.Lib.println(message);
        #else
            trace(message);
        #end
    }
}
