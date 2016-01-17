package org.zamedev.ui.tools.parser;

import org.zamedev.ui.errors.UiParseError;
import org.zamedev.ui.res.Configuration;
import org.zamedev.ui.tools.generator.GenPosition;

class ConfigurationHelper {
    public static function parse(qualifiers : Array<String>, path : String) : Configuration {
        var configuration = new Configuration();

        for (item in qualifiers) {
            if (item == '') {
                continue;
            }

            if (item == 'long' || item == 'notlong') {
                if (configuration.aspect != "") {
                    throw new UiParseError('Duplicate qualifier "${item}" in "${path}"', new GenPosition(null, path));
                }

                configuration.aspect = item;
            } else if (item.length == 2) {
                if (configuration.locale != "") {
                    throw new UiParseError('Duplicate qualifier "${item}" in "${path}"', new GenPosition(null, path));
                }

                configuration.locale = item;
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
}
