package org.zamedev.ui;

import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.system.Capabilities;
import org.zamedev.ui.internal.ApplicationStage;
import org.zamedev.ui.res.Inflater;
import org.zamedev.ui.res.ResourceManager;

// TODO:
// http://www.yiiframework.com/doc-2.0/guide-tutorial-i18n.html

class Application extends Sprite implements Context {
    #if debug
        private var fps:FPS;
    #end

    private var _applicationStage:ApplicationStage;
    private var _locale:String;
    private var _resourceManager:ResourceManager;
    private var _inflater:Inflater;
    private var _currentScene:Scene;

    public var context(get, null):Context;
    public var application(get, null):Application;
    public var applicationStage(get, null):ApplicationStage;
    public var locale(get, set):String;
    public var resourceManager(get, null):ResourceManager;
    public var inflater(get, null):Inflater;

    public function new() {
        super();

        _applicationStage = new ApplicationStage();
        _locale = Capabilities.language;
        _resourceManager = new ResourceManager(this);
        _inflater = new Inflater(this);
        _currentScene = null;

        create();
    }

    private function create():Void {
        addChild(_applicationStage);

        #if debug
            addChild(fps = new FPS(16, 16, 0xff0000));
        #end
    }

    public function changeScene(scene:Scene):Void {
        if (_currentScene == scene) {
            return;
        }

        if (_currentScene != null) {
            _currentScene.removeFromApplicationStage();
        }

        _currentScene = scene;

        if (_currentScene != null) {
            _currentScene.addToApplicationStage();
        }
    }

    @:noCompletion
    private function get_context():Context {
        return this;
    }

    @:noCompletion
    private function get_application():Application {
        return this;
    }

    @:noCompletion
    private function get_applicationStage():ApplicationStage {
        return _applicationStage;
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

    @:noCompletion
    private function get_inflater():Inflater {
        return _inflater;
    }

    /*
    private var prevTime:Int = -1;

    ... {
    addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function onEnterFrame(_):Void {
        var dt:Float;

        if (prevTime < 0) {
            prevTime = Lib.getTimer();
            dt = 0.0;
        } else {
            var currentTime = Lib.getTimer();
            dt = (currentTime - prevTime) / 1000.0;
            prevTime = currentTime;
        }

        if (dt > 10.0) {
            dt = 10.0;
        }

        while (dt > 0.0) {
            update(dt);
            dt -= 1.0;
        }

        render();
    }
    */
}
