package org.zamedev.ui.tools.generator;

import org.zamedev.ui.res.Configuration;

class GenPosition {
    public var configuration : Configuration;
    public var fileName : String;
    public var lineNum : Null<Int>;
    public var column : Null<Int>;

    public function new(configuration : Configuration, fileName : String, ?lineNum : Null<Int>, ?column : Null<Int>) {
        this.configuration = configuration;
        this.fileName = fileName;
        this.lineNum = lineNum;
        this.column = column;
    }

    public function getDisplayName() : String {
        var result = 'At ${fileName}';

        if (lineNum != null) {
            result += ':${lineNum}';

            if (column != null) {
                result += ' col ${column}';
            }
        }

        return result;
    }
}
