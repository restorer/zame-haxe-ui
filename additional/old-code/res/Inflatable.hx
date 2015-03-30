package org.zamedev.ui.res;

interface Inflatable {
    public function inflate(name:String, value:TypedValue):Bool;
    public function onInflateStarted():Void;
    public function onInflateFinished():Void;
}
