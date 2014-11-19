package org.zamedev.ui;

import org.zamedev.ui.internal.ApplicationStage;
import org.zamedev.ui.res.ResourceManager;

class ContextWrapper implements Context {
    public var context(default, null):Context;
    public var applicationStage(get, null):ApplicationStage;
    public var locale(get, set):String;
    public var resourceManager(get, null):ResourceManager;

    public function new(context:Context) {
        this.context = context;
    }

    @:noCompletion
    private function get_applicationStage():ApplicationStage {
        return context.applicationStage;
    }

    @:noCompletion
    private function get_locale():String {
        return context.locale;
    }

    @:noCompletion
    private function set_locale(value:String):String {
        context.locale = value;
        return value;
    }

    @:noCompletion
    private function get_resourceManager():ResourceManager {
        return context.resourceManager;
    }
}
