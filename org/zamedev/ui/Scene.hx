package org.zamedev.ui;

import org.zamedev.ui.view.View;

class Scene extends ContextWrapper {
    private var _contentView:View;

    public var contentView(get, null):View;

    public function new(context:Context) {
        super(context);
        _contentView = null;
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

        if (_contentView != null) {
            _contentView.addToContainer(context.applicationStage);
        }
    }

    public function addToApplicationStage():Void {
        if (_contentView != null) {
            _contentView.addToContainer(context.applicationStage);
        }
    }

    public function removeFromApplicationStage():Void {
        if (_contentView != null) {
            _contentView.removeFromContainer();
        }
    }
}
