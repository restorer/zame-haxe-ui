package org.zamedev.ui;

import motion.Actuate;
import openfl.events.Event;
import org.zamedev.ui.internal.SceneSprite;
import org.zamedev.ui.view.View;

class Scene extends ContextWrapper {
    private var _contentView:View;
    private var sceneSprite:SceneSprite;
    private var addedToApplicationStage:Bool;

    public var contentView(get, set):View;

    public function new(context:Context) {
        super(context);

        _contentView = null;
        sceneSprite = new SceneSprite(context.applicationStage);
        addedToApplicationStage = false;

        create();
    }

    public function create():Void {
    }

    @:noCompletion
    private function get_contentView():View {
        return _contentView;
    }

    private function set_contentView(view:View):View {
        if (_contentView == view) {
            return view;
        }

        if (_contentView != null) {
            _contentView.removeFromContainer();
        }

        _contentView = view;
        _contentView.addToContainer(sceneSprite);

        return view;
    }

    public function addToApplicationStage():Void {
        if (addedToApplicationStage) {
            return;
        }

        addedToApplicationStage = true;

        Actuate.apply(sceneSprite, { alpha: 0, y: context.applicationStage.height / 10.0 });
        context.applicationStage.addChild(sceneSprite);

        Actuate.tween(sceneSprite, 0.5, { alpha: 1, y: 0 }).onComplete(function():Void {
            sceneSprite.dispatchEvents = true;
            dispatchEvent(new Event(Event.ADDED_TO_STAGE));
        });
    }

    public function removeFromApplicationStage():Void {
        if (!addedToApplicationStage) {
            return;
        }

        addedToApplicationStage = false;
        sceneSprite.dispatchEvents = false;

        Actuate.tween(sceneSprite, 0.5, { alpha: 0, y: context.applicationStage.height / 10.0 });
    }
}
