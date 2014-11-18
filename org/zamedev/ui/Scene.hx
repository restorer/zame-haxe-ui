package org.zamedev.ui;

import org.zamedev.ui.view.View;

class Scene extends ContextWrapper {
    public var contentView:View;

    public function new(context:Context) {
        super(context);

        contentView = null;
        create();
    }

    public function create():Void {
    }

    private function setContentView(view:View):Void {
        contentView = view;
    }
}
