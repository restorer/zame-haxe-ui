package org.zamedev.ui.tools;

import haxe.io.Path;
import neko.Lib;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.graphics.DrawableType;
import sys.FileSystem;
import sys.io.File;

class UiBuilder {
    private static var assetsPath:String;
    private static var resGenerator:ResGenerator;
    private static var resParser:ResParser;

    private static function processAssets(basePath:String):Void {
        for (name in FileSystem.readDirectory(basePath)) {
            var path = Path.join([basePath, name]);

            if (FileSystem.isDirectory(path)) {
                processAssets(path);
                continue;
            }

            switch (Path.extension(name).toLowerCase()) {
                case "png" | "jpg" | "jpeg" | "bmp":
                    if (~/^\/drawable/.match(path.substr(assetsPath.length))) {
                        resGenerator.putDrawable(
                            Path.withoutExtension(Path.withoutDirectory(path)),
                            new Drawable(DrawableType.BITMAP, path.substr(assetsPath.length + 1))
                        );
                    }

                case "xml":
                    resParser.tryParse(File.getContent(path));
            }
        }
    }

    public static function main() {
        var rootPath = Sys.args()[0];
        var sourcePath = Path.join([rootPath, "source"]);

        assetsPath = Path.join([rootPath, "assets"]);

        resGenerator = new ResGenerator();
        resParser = new ResParser();

        Lib.println("Processing assets ...");
        processAssets(assetsPath);

        Lib.println("Process resources ...");
        resParser.toGenerator(resGenerator);

        Lib.println("Saving R.hx ...");
        FileSystem.createDirectory(sourcePath);
        File.saveContent(Path.join([sourcePath, "R.hx"]), resGenerator.generate());
    }
}
