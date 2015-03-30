package org.zamedev.ui.widget;

import motion.Actuate;
import motion.easing.Linear;
import openfl.display.Sprite;
import openfl.events.Event;
import org.zamedev.ui.Context;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.res.MeasureSpec;
import org.zamedev.ui.res.Styleable;
import org.zamedev.ui.view.ImageView;
import org.zamedev.ui.view.View;

class Progress extends View {
    private var imageView:ImageView;
    private var _pivotSprite:Sprite;

    public var drawable(get, set):Drawable;

    @:keep
    public function new(context:Context) {
        super(context);

        _sprite.addChild(_pivotSprite = new Sprite());

        imageView = new ImageView(context);
        _pivotSprite.addChild(imageView._sprite);

        addEventListener(Event.ADDED_TO_STAGE, onProgressAddedToApplicationStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onProgressRemovedFromApplicationStage);
    }

    override private function _inflate(attId:Styleable, value:Dynamic):Bool {
        if (super._inflate(attId, value)) {
            return true;
        }

        switch (attId) {
            case Styleable.drawable:
                drawable = cast value;
                return true;

            default:
                return false;
        }
    }

    override private function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
        if (super.measureAndLayout(widthSpec, heightSpec)) {
            return true;
        }

        imageView.selfLayout(widthSpec, heightSpec);

        _width = imageView.width;
        _height = imageView.height;

        var midX = _width / 2;
        var midY = _height / 2;

        _pivotSprite.x = midX;
        _pivotSprite.y = midY;

        imageView.x = - midX;
        imageView.y = - midY;

        return true;
    }

    private function onProgressAddedToApplicationStage(e:Event):Void {
        imageView.dispatchEvent(e);
        Actuate.tween(_pivotSprite, 1.5, { rotation: 359 }).ease(Linear.easeNone).repeat();
        // Actuate.tween(_pivotSprite, 1.5, { rotation: 359 }).ease(motion.easing.Sine.easeInOut).repeat();
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
