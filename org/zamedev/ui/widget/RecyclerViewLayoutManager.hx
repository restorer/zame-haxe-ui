package org.zamedev.ui.widget;

import org.zamedev.ui.view.View;

typedef ScrollPosition = {
    x:Float,
    y:Float,
};

class RecyclerViewLayoutManager {
    public var x(default, null):Float;
    public var y(default, null):Float;
    public var px(default, null):Float;
    public var py(default, null):Float;

    private var maxWidth:Float;
    private var maxHeight:Float;

    public function new() {
    }

    public function init(x:Float, y:Float, maxWidth:Float, maxHeight:Float) {
        this.x = x;
        this.y = y;
        this.px = x;
        this.py = y;
        this.maxWidth = maxWidth;
        this.maxHeight = maxHeight;
    }

    public function prepend(view:View):Void {
        py -= view.height;
        view.x = px;
        view.y = py;
    }

    public function layout(view:View):Void {
        view.x = x;
        view.y = y;
        y += view.height;
    }

    public function canPrepend():Bool {
        return (py > 0);
    }

    public function isBeforeStart(view:View):Bool {
        return ((view.y + view.height) <= 0);
    }

    public function isAtEnd(view:View):Bool {
        return ((view.y + view.height) >= maxHeight);
    }

    public function computePrevScrollPosition(view:View):ScrollPosition {
        return {
            x: 0.0,
            y: view.y + 1.0,
        };
    }

    public function computeNextScrollPosition(view:View):ScrollPosition {
        return {
            x: 0.0,
            y: view.y + view.height,
        };
    }
}
