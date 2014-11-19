package org.zamedev.ui;

import org.zamedev.ui.view.View;
import motion.Actuate;

class Scene extends ContextWrapper {
    private var _contentView:View;
    private var addedToApplicationStage:Bool;

    public var contentView(get, null):View;

    public function new(context:Context) {
        super(context);

        _contentView = null;
        addedToApplicationStage = false;

        create();
    }

    public function create():Void {
    }

    @:noCompletion
    private function get_contentView():View {
        return _contentView;
    }

    private function setContentView(view:View):Void {
        if (_contentView == view) {
            return;
        }

        if (_contentView != null) {
            _contentView.removeFromContainer();
        }

        _contentView = view;

        if (addedToApplicationStage) {
            _contentView.addToContainer(context.applicationStage);
        }
    }

    public function addToApplicationStage():Void {
        if (addedToApplicationStage) {
            return;
        }

        addedToApplicationStage = true;

        if (_contentView != null) {
            Actuate.apply(_contentView.sprite, { alpha: 0, y: context.applicationStage.height / 10.0 });
            _contentView.addToContainer(context.applicationStage);
            Actuate.tween(_contentView.sprite, 0.5, { alpha: 1, y: 0 });
        }
    }

    public function removeFromApplicationStage():Void {
        if (!addedToApplicationStage) {
            return;
        }

        addedToApplicationStage = false;

        if (_contentView != null) {
            Actuate.tween(_contentView.sprite, 0.5, { alpha: 0, y: context.applicationStage.height / 10.0 }).onComplete(function():Void {
                _contentView.removeFromContainer();
            });
        }
    }
}
