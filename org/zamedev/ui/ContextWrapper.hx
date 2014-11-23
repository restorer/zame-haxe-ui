package org.zamedev.ui;

import openfl.events.EventDispatcher;
import org.zamedev.ui.internal.ApplicationStage;
import org.zamedev.ui.res.Inflater;
import org.zamedev.ui.res.ResourceManager;

class ContextWrapper extends EventDispatcher implements Context {
    public var context(default, null):Context;
    public var application(get, null):Application;
    public var applicationStage(get, null):ApplicationStage;
    public var locale(get, set):String;
    public var resourceManager(get, null):ResourceManager;
    public var inflater(get, null):Inflater;

    public function new(context:Context) {
        super();
        this.context = context;
    }

    @:noCompletion
    private function get_application():Application {
        return context.application;
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

    @:noCompletion
    private function get_inflater():Inflater {
        return context.inflater;
    }
}
