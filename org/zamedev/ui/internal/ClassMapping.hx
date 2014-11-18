package org.zamedev.ui.internal;

import org.zamedev.ui.view.ImageView;
import org.zamedev.ui.view.Rect;
import org.zamedev.ui.view.TextView;
import org.zamedev.ui.view.View;
import org.zamedev.ui.widget.AbsoluteLayout;
import org.zamedev.ui.widget.Button;
import org.zamedev.ui.widget.LinearLayout;
import org.zamedev.ui.widget.Radio;

class ClassMapping {
    public static var classMap:Map<String, String>;

    static function __init__() {
        classMap = new Map<String, String>();

        classMap["ImageView"] = "org.zamedev.ui.view.ImageView";
        classMap["Rect"] = "org.zamedev.ui.view.Rect";
        classMap["TextView"] = "org.zamedev.ui.view.TextView";
        classMap["View"] = "org.zamedev.ui.view.View";
        classMap["AbsoluteLayout"] = "org.zamedev.ui.widget.AbsoluteLayout";
        classMap["Button"] = "org.zamedev.ui.widget.Button";
        classMap["LinearLayout"] = "org.zamedev.ui.widget.LinearLayout";
        classMap["Radio"] = "org.zamedev.ui.widget.Radio";
    }
}
