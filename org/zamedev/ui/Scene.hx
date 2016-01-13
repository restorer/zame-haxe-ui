package org.zamedev.ui;

import motion.Actuate;
import openfl.display.Shape;
import openfl.events.Event;
import org.zamedev.ui.internal.SceneSprite;
import org.zamedev.ui.view.View;

class Scene extends ContextWrapper {
    public static inline var TRANSITION_DURATION = 0.5;

    public static inline var ADDING_TO_STAGE = "addingToStage";
    public static inline var COVERED = "covered";
    public static inline var UNCOVERED = "uncovered";

    private var _contentView : View;
    private var sceneSprite : SceneSprite;
    private var maskShape : Shape;
    private var coverMaskColor : Int = 0x000000;
    private var coverMaskAlpha : Float = 0.75;
    private var addedToApplicationStage : Bool;
    private var isCovered : Bool;

    public var contentView(get, set) : View;
    public var sceneParams : Dynamic = null;

    public function new(context : Context) {
        super(context);

        _contentView = null;
        sceneSprite = new SceneSprite(context.applicationStage);
        maskShape = new Shape();
        addedToApplicationStage = false;
        isCovered = false;

        maskShape.visible = false;
        context.applicationStage.addEventListener(Event.RESIZE, onRootResize);

        create();
    }

    public function create() : Void {
    }

    @:noCompletion
    private function get_contentView() : View {
        return _contentView;
    }

    private function set_contentView(view : View) : View {
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

    public function addToApplicationStage() : Void {
        if (addedToApplicationStage) {
            return;
        }

        addedToApplicationStage = true;
        Actuate.apply(sceneSprite, { alpha: 0.0, y: context.applicationStage.height / 10.0 });

        context.applicationStage.addChild(sceneSprite);
        context.applicationStage.addChild(maskShape);

        if (_contentView != null) {
            _contentView.dispatchEvent(new Event(Event.ADDED_TO_STAGE));
        }

        dispatchEvent(new Event(ADDING_TO_STAGE));

        Actuate.tween(sceneSprite, TRANSITION_DURATION, { alpha: 1.0, y: 0.0 }).onComplete(function():Void {
            sceneSprite.dispatchEvents = true;
            dispatchEvent(new Event(Event.ADDED_TO_STAGE));
        });
    }

    public function removeFromApplicationStage() : Void {
        if (!addedToApplicationStage) {
            return;
        }

        addedToApplicationStage = false;
        sceneSprite.dispatchEvents = false;

        var event = new Event(Event.REMOVED_FROM_STAGE);

        if (_contentView != null) {
            _contentView.dispatchEvent(event);
        }

        dispatchEvent(event);

        if (isCovered) {
            isCovered = false;
            Actuate.tween(maskShape, TRANSITION_DURATION, { alpha: 0.0 });
        }

        Actuate.tween(sceneSprite, TRANSITION_DURATION, { alpha: 0.0, y: context.applicationStage.height / 10.0 }).onComplete(function() {
            context.applicationStage.removeChild(maskShape);
            context.applicationStage.removeChild(sceneSprite);
        });
    }

    public function onCovered() : Void {
        if (isCovered) {
            return;
        }

        isCovered = true;
        sceneSprite.dispatchEvents = false;
        dispatchEvent(new Event(COVERED));
        onRootResize(null);

        Actuate.apply(maskShape, { alpha: 0.0 });
        Actuate.tween(maskShape, TRANSITION_DURATION, { alpha: coverMaskAlpha });
    }

    public function onUncovered() : Void {
        if (!isCovered) {
            return;
        }

        isCovered = false;

        Actuate.tween(maskShape, TRANSITION_DURATION, { alpha: 0.0 }).onComplete(function() {
            sceneSprite.dispatchEvents = true;
            dispatchEvent(new Event(UNCOVERED));
        });
    }

    private function onRootResize(_) : Void {
        if (!isCovered) {
            return;
        }

        var appStage = context.applicationStage;

        maskShape.graphics.clear();
        maskShape.graphics.beginFill(coverMaskColor);

        maskShape.graphics.drawRect(
            - appStage.x / appStage.scaleX,
            - appStage.y / appStage.scaleY,
            appStage.width + (appStage.x / appStage.scaleX) * 2.0,
            appStage.height + (appStage.y / appStage.scaleY) * 2.0
        );

        maskShape.graphics.endFill();
    }
}
