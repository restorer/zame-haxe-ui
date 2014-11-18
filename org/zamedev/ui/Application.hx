package org.zamedev.ui;

import openfl.display.FPS;
import openfl.display.Sprite;
import org.zamedev.ui.internal.RootSprite;
import org.zamedev.ui.res.ResourceManager;

class Application extends Sprite implements Context {
    #if debug
        private var fps:FPS;
    #end

    public var context(default, null):Context;
    public var rootSprite(get, null):RootSprite;
    public var locale(get, set):String;
    public var resourceManager(get, null):ResourceManager;

    public function new() {
        super();

        context = new ApplicationContext();
        addChild(context.rootSprite);

        #if debug
            addChild(fps = new FPS(16, 16, 0xff0000));
        #end
    }

    public function addScene(scene:Scene) {
        if (scene.contentView != null) {
            scene.contentView.addToDisplayObjectContainer(rootSprite);
        }
    }

    @:noCompletion
    private function get_rootSprite():RootSprite {
        return context.rootSprite;
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
