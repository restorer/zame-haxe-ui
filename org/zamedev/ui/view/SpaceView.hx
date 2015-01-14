package org.zamedev.ui.view;

import org.zamedev.ui.res.MeasureSpec;

class SpaceView extends View {
    override private function measureAndLayout(widthSpec:MeasureSpec, heightSpec:MeasureSpec):Bool {
        if (super.measureAndLayout(widthSpec, heightSpec)) {
            return true;
        }

        switch (widthSpec) {
            case MeasureSpec.UNSPECIFIED:
                _width = 0;

            case MeasureSpec.AT_MOST(size) | MeasureSpec.EXACT(size):
                _width = size;
        }

        switch (heightSpec) {
            case MeasureSpec.UNSPECIFIED:
                _height = 0;

            case MeasureSpec.AT_MOST(size) | MeasureSpec.EXACT(size):
                _height = size;
        }

        return true;
    }
}
