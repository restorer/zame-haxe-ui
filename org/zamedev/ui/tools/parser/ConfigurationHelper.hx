package org.zamedev.ui.tools.parser;

import org.zamedev.ui.errors.UiParseError;
import org.zamedev.ui.res.Configuration;
import org.zamedev.ui.tools.generator.GenPosition;

class ConfigurationHelper {
    public static function parse(qualifiers : Array<String>, path : String) : Configuration {
        var configuration = new Configuration();

        for (item in qualifiers) {
            if (item == "") {
                continue;
            }

            if (item == "long" || item == "notlong") {
                checkAndSet(configuration, "aspect", item, path);
            } else if (item == "port" || item == "land") {
                checkAndSet(configuration, "orientation", item, path);
            } else if (item == "android" || item == "ios" || item == "html5") {
                checkAndSet(configuration, "target", item, path);
            } else if (item == "dom" || item == "canvas" || item == "webgl") {
                checkAndSet(configuration, "subTarget", item, path);
            } else if (item.length == 2) {
                checkAndSet(configuration, "locale", item, path);
            } else {
                throw new UiParseError('Invalid qualifier "${item}" in "${path}"', new GenPosition(null, path));
            }
        }

        if (configuration.toQualifierString() != qualifiers.join("-")) {
            throw new UiParseError('Invalid qualifiers order in "${path}"', new GenPosition(null, path));
        }

        return configuration;
    }

    // Computes qualifier keys for search (with empty qualifier key).
    // For example, for ["ru", "long", "port"] following list will be generated:
    //
    // "ru-long-port"
    // "ru-long"
    // "ru"
    // "long-port"
    // "long"
    // "port"
    // ""
    public static function computeQualifierKeys(configuration : Configuration) : Array<String> {
        var qualifiers : Array<String> = configuration.toArray();
        var result : Array<String> = [];

        if (qualifiers.length != 0) {
            for (i in 0 ... qualifiers.length) {
                for (j in -qualifiers.length ... -i) {
                    result.push(qualifiers.slice(i, -j).join("-"));
                }
            }
        }

        result.push("");
        return result;
    }

    private static function checkAndSet(configuration : Configuration, field : String, value : String, path : String) : Void {
        if (cast(Reflect.getProperty(configuration, field), String) != "") {
            throw new UiParseError('Duplicate qualifier "${field}" in "${path}"', new GenPosition(null, path));
        }

        Reflect.setProperty(configuration, field, value);
    }
}
