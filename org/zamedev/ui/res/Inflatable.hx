package org.zamedev.ui.res;

interface Inflatable {
    public function inflate(attId:Styleable, value:Dynamic):Void;
    public function onInflateStarted():Void;
    public function onInflateFinished():Void;
}
