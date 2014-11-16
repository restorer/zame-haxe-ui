package org.zamedev.ui;

import org.zamedev.ui.res.ResourceManager;

class ApplicationContext implements Context {
    private var _locale:String;
    private var _resourceManager:ResourceManager;

    public var locale(get, set):String;
    public var resourceManager(get, null):ResourceManager;

    public function new() {
        _locale = null;
        _resourceManager = new ResourceManager(this);
    }

    @:noCompletion
    private function get_locale():String {
        return _locale;
    }

    @:noCompletion
    private function set_locale(value:String):String {
        _locale = value;
        _resourceManager.reload();
        return value;
    }

    @:noCompletion
    private function get_resourceManager():ResourceManager {
        return _resourceManager;
    }
}
