package org.zamedev.ui.errors;

class UiError {
    public var message(default, null) : String;

    public function new(?message : String) : Void {
        this.message = message;
    }

    public function toString() : String {
        return (Type.getClassName(Type.getClass(this)) + (message == null ? "" : ': ${message}'));
    }
}
