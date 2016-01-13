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
    #if (debug || fps)
        private var fps : FPS;
    #end

    private var _applicationStage : ApplicationStage;
    private var _locale : String;
    private var _resourceManager : ResourceManager;
    private var _inflater : Inflater;
    private var _sceneStack : List<Scene>;

    public var context(get, null) : Context;
    public var application(get, null) : Application;
    public var applicationStage(get, null) : ApplicationStage;
    public var locale(get, set) : String;
    public var resourceManager(get, null) : ResourceManager;
    public var inflater(get, null) : Inflater;

    public function new() {
        super();

        _applicationStage = new ApplicationStage();

        #if ios
            // work-around for bug in lime legacy
            _locale = "en-US";
        #else
            _locale = Capabilities.language;
        #end

        _resourceManager = new ResourceManager(this);
        _inflater = new Inflater(this);
        _sceneStack = new List<Scene>();

        create();
    }

    private function create() : Void {
        addChild(_applicationStage);

        #if (debug || fps)
            addChild(fps = new FPS(16, 16, 0xff0000));
        #end
    }

    public function changeScene(scene : Scene, ?sceneParams : Dynamic, ?searchForScene : Scene) : Void {
        if (searchForScene != null) {
            while (_sceneStack.length != 0 && _sceneStack.first() != searchForScene) {
                _sceneStack.pop().removeFromApplicationStage();
            }
        }

        var topScene = _sceneStack.first();

        if (topScene == scene) {
            return;
        }

        if (topScene != null) {
            topScene.removeFromApplicationStage();
            _sceneStack.pop();
        }

        if (scene != null) {
            _sceneStack.push(scene);
            scene.sceneParams = sceneParams;
            scene.addToApplicationStage();
        }
    }

    public function pushScene(scene : Scene, ?sceneParams : Dynamic) : Void {
        if (scene == null) {
            return;
        }

        var topScene = _sceneStack.first();

        if (topScene != null) {
            topScene.onCovered();
        }

        _sceneStack.push(scene);
        scene.sceneParams = sceneParams;
        scene.addToApplicationStage();
    }

    public function popScene() : Void {
        var scene = _sceneStack.pop();

        if (scene != null) {
            scene.removeFromApplicationStage();
        }

        var topScene = _sceneStack.first();

        if (topScene != null) {
            topScene.onUncovered();
        }
    }

    @:noCompletion
    private function get_context() : Context {
        return this;
    }

    @:noCompletion
    private function get_application() : Application {
        return this;
    }

    @:noCompletion
    private function get_applicationStage() : ApplicationStage {
        return _applicationStage;
    }

    @:noCompletion
    private function get_locale() : String {
        return _locale;
    }

    @:noCompletion
    private function set_locale(value : String) : String {
        _locale = value;
        _resourceManager.reload();
        return value;
    }

    @:noCompletion
    private function get_resourceManager() : ResourceManager {
        return _resourceManager;
    }

    @:noCompletion
    private function get_inflater() : Inflater {
        return _inflater;
    }
}
