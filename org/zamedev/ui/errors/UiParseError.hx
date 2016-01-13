package org.zamedev.ui.errors;

import org.zamedev.ui.tools.generator.GenPosition;

class UiParseError {
    public var message(default, null) : String;
    public var pos(default, null) : GenPosition;

    public function new(?message : String, ?pos : GenPosition) : Void {
        this.message = message;
        this.pos = pos;
    }

    public function toString() : String {
        return ((pos == null ? "" : '${pos.getDisplayName()}: ') + (message == null ? "" : message));
    }
}
