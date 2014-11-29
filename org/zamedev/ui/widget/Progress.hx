package org.zamedev.ui.widget;

import openfl.display.Sprite;
import openfl.events.Event;
import org.zamedev.ui.Context;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.TypedValue;
import org.zamedev.ui.view.ImageView;
import org.zamedev.ui.view.View;
import motion.Actuate;
import motion.easing.Linear;

class Progress extends View {
    private var imageView:ImageView;
    private var _pivotSprite:Sprite;

    public var drawable(get, set):Drawable;

    public function new(context:Context) {
        super(context);

        _sprite.addChild(_pivotSprite = new Sprite());

        imageView = new ImageView(context);
        _pivotSprite.addChild(imageView._sprite);

        addEventListener(Event.ADDED_TO_STAGE, onProgressAddedToApplicationStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onProgressRemovedFromApplicationStage);
    }

    override public function inflate(name:String, value:TypedValue):Bool {
        if (super.inflate(name, value)) {
            return true;
        }

        switch (name) {
            case "drawable":
                drawable = value.resolveDrawable();
                return true;
        }

        return false;
    }

    override private function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
        if (super.measureAndLayout(widthSpec, heightSpec)) {
            return true;
        }

        imageView.selfLayout(widthSpec, heightSpec);

        _width = imageView.width;
        _height = imageView.height;

        _pivotSprite.x = _width / 2;
        _pivotSprite.y = _height / 2;

        imageView.x = - _width / 2;
        imageView.y = - _height / 2;

        return true;
    }

    private function onProgressAddedToApplicationStage(e:Event):Void {
        imageView.dispatchEvent(e);
        Actuate.tween(_pivotSprite, 2, { rotation: 359 }).ease(Linear.easeNone).repeat();
    }

    private function onProgressRemovedFromApplicationStage(e:Event):Void {
        imageView.dispatchEvent(e);

        Actuate.stop(_pivotSprite, "rotation");
        Actuate.apply(_pivotSprite, { rotation: 0 });
    }

    @:noCompletion
    private function get_drawable():Drawable {
        return imageView.drawable;
    }

    @:noCompletion
    private function set_drawable(value:Drawable):Drawable {
        imageView.drawable = value;
        return value;
    }
}
