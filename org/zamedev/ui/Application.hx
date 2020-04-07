package org.zamedev.ui;

import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.system.Capabilities;
import org.zamedev.ui.internal.ApplicationStage;
import org.zamedev.ui.res.Configuration;
import org.zamedev.ui.res.Hints;
import org.zamedev.ui.res.Inflater;
import org.zamedev.ui.res.ResourceManager;

#if extension_orientation
    import extension.eightsines.EsOrientation;
#end


// TODO:
// http://www.yiiframework.com/doc-2.0/guide-tutorial-i18n.html

class Application extends Sprite implements Context {
    #if (debug || ui_fps)
        private var fps : FPS;
    #end

    private var _applicationStage : ApplicationStage;
    private var _configuration : Configuration;
    private var _resourceManager : ResourceManager = null;
    private var _inflater : Inflater;
    private var _hints : Hints;
    private var _sceneStack : List<Scene>;

    public var context(get, null) : Context;
    public var application(get, null) : Application;
    public var applicationStage(get, null) : ApplicationStage;
    public var configuration(get, set) : Configuration;
    public var resourceManager(get, null) : ResourceManager;
    public var inflater(get, null) : Inflater;
    public var hints(get, null) : Hints;

    public function new() {
        super();

        _applicationStage = new ApplicationStage();
        _configuration = new Configuration();

        detectConfiguration();

        _resourceManager = new ResourceManager(this);
        _inflater = new Inflater(this);
        _hints = new Hints();
        _sceneStack = new List<Scene>();

        create();
    }

    private function detectConfiguration() : Void {
        var stageWidth = (stage.stageWidth < 1 ? 1 : stage.stageWidth);
        var stageHeight = (stage.stageHeight < 1 ? 1 : stage.stageHeight);

        #if (ios && legacy)
            // work-around for bug in lime legacy
            _configuration.locale = "en";
        #else
            _configuration.locale = ~/\-.*$/.replace(Capabilities.language, "");

            // just for case
            if (_configuration.locale == "") {
                _configuration.locale = "en";
            }
        #end

        // Phones:
        // iPhone 3G - 320 x 480 -> 1.5
        // iPhone 4 - 640 x 960 -> 1.5
        // iPhone 5 - 640 x 1136 -> 1.775
        // iPhone 6 - 750 x 1334 -> ~ 1.7787
        // iPhone 6+ - 1080 x 1920 -> ~ 1.778

        // Tablets:
        // iPad - 1024 x 768 -> ~ 1.334
        // iPad Pro - 2732 x 2048 -> ~ 1.334
        // iPad Air - 2048 x 1536 -> ~ 1.334

        // https://design.google.com/devices/

        // Phones:
        // HTC One M8 / M9 - 1080 x 1920 -> ~ 1.778
        // LG G2 - 1080 x 1920 -> ~ 1.778
        // LG G3 - 1440 x 2560 -> ~ 1.778
        // Moto G / X - 720 x 1280 -> ~ 1.778
        // Moto X 2nd Gen - 1080 x 1920 -> ~ 1.778
        // Nexus 4 - 768 x 1280 -> ~ 1.667
        // Nexus 5 / 5X - 1080 x 1920 -> ~ 1.778
        // Nexus 6 / 6P - 1440 x 2560 -> ~ 1.778
        // Nexus 7 ('12) - 800 x 1280 -> 1.6 (actually tablet, but with port orientation)
        // Nexus 7 ('13) - 1200 x 1920 -> 1.6 (actually tablet, but with port orientation)
        // Samsung Galaxy Note 4 - 1440 x 2560 -> ~ 1.778
        // Samsung Galaxy S5 - 1080 x 1920 -> ~ 1.778
        // Samsung Galaxy S6 - 1440 x 2560 -> ~ 1.778
        //

        // Tablets:
        // Nexus 10 - 1280 x 800 -> 1.6
        // Nexus 9 - 2048 x 1536 -> ~ 1.334
        // Samsung Galaxy Tab 10 - 1280 x 800 -> 1.6

        _configuration.aspect = (Math.max(stageWidth, stageHeight) / Math.min(stageWidth, stageHeight) > 1.49 ? "long" : "notlong");

        #if html5
            _configuration.orientation = "land";
        #else
            _configuration.orientation = (stageWidth > stageHeight ? "land" : "port");
        #end

        #if android
            _configuration.target = "android";
        #elseif ios
            _configuration.target = "ios";
        #elseif html5
            _configuration.target = "html5";

            #if dom
                _configuration.subTarget = "dom";
            #elseif canvas
                _configuration.subTarget = "canvas";
            #elseif webgl
                _configuration.subTarget = "webgl";
            #end
        #end
    }

    // Doesn't actually change orientation if compiled without extension-orientation.
    private function usePhoneAsPortTabletAsLong() : Void {
        #if ios
            _configuration.orientation = (_configuration.aspect == "long" ? "port" : "land");
        #end

        #if extension_orientation
            EsOrientation.setScreenOrientation(_configuration.orientation == "port"
                ? EsOrientation.ORIENTATION_PORTRAIT
                : EsOrientation.ORIENTATION_LANDSCAPE
            );
        #end

        if (_resourceManager != null) {
            _resourceManager.reload();
        }
    }

    private function create() : Void {
        addChild(_applicationStage);

        #if (debug || ui_fps)
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
    private function get_configuration() : Configuration {
        return _configuration;
    }

    @:noCompletion
    private function set_configuration(value : Configuration) : Configuration {
        _configuration = value;
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

    @:noCompletion
    private function get_hints() : Hints {
        return _hints;
    }
}
