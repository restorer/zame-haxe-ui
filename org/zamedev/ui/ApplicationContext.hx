package org.zamedev.ui;

import org.zamedev.ui.internal.RootSprite;
import org.zamedev.ui.res.ResourceManager;

class ApplicationContext implements Context {
    private var _rootSprite:RootSprite;
    private var _locale:String;
    private var _resourceManager:ResourceManager;

    public var rootSprite(get, null):RootSprite;
    public var locale(get, set):String;
    public var resourceManager(get, null):ResourceManager;

    public function new() {
        _rootSprite = new RootSprite();
        _locale = null;
        _resourceManager = new ResourceManager(this);
    }

    @:noCompletion
    private function get_rootSprite():RootSprite {
        return _rootSprite;
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
