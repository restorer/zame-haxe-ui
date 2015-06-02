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

    public var orientation:LinearLayoutOrientation;

    public function new() {
        this.orientation = LinearLayoutOrientation.VERTICAL;
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
        if (orientation == LinearLayoutOrientation.VERTICAL) {
            py -= view.height;
        } else {
            px -= view.width;
        }

        view.x = px;
        view.y = py;
    }

    public function layout(view:View):Void {
        view.x = x;
        view.y = y;

        if (orientation == LinearLayoutOrientation.VERTICAL) {
            y += view.height;
        } else {
            x += view.width;
        }
    }

    public function canPrepend():Bool {
        if (orientation == LinearLayoutOrientation.VERTICAL) {
            return (py > 0);
        } else {
            return (px > 0);
        }
    }

    public function isBeforeStart(view:View):Bool {
        if (orientation == LinearLayoutOrientation.VERTICAL) {
            return ((view.y + view.height) <= 0);
        } else {
            return ((view.x + view.width) <= 0);
        }
    }

    public function isAtEnd(view:View):Bool {
        if (orientation == LinearLayoutOrientation.VERTICAL) {
            return ((view.y + view.height) >= maxHeight);
        } else {
            return ((view.x + view.width) >= maxWidth);
        }
    }

    public function computePrevScrollPosition(view:View):ScrollPosition {
        if (orientation == LinearLayoutOrientation.VERTICAL) {
            return {
                x: 0.0,
                y: view.y + 1.0,
            };
        } else {
            return {
                x: view.x + 1.0,
                y: 0.0,
            };
        }
    }

    public function computeNextScrollPosition(view:View):ScrollPosition {
        if (orientation == LinearLayoutOrientation.VERTICAL) {
            return {
                x: 0.0,
                y: view.y + view.height,
            };
        } else {
            return {
                x: view.x + view.width,
                y: 0.0,
            };
        }
    }
}
