package org.zamedev.ui.internal;

import org.zamedev.ui.view.ImageView;
import org.zamedev.ui.view.Rect;
import org.zamedev.ui.view.TextView;
import org.zamedev.ui.view.View;
import org.zamedev.ui.widget.AbsoluteLayout;
import org.zamedev.ui.widget.Button;
import org.zamedev.ui.widget.FrameLayout;
import org.zamedev.ui.widget.LinearLayout;
import org.zamedev.ui.widget.Progress;
import org.zamedev.ui.widget.Radio;
import org.zamedev.ui.widget.RecyclerView;
import org.zamedev.ui.widget.Toggle;

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
        classMap["FrameLayout"] = "org.zamedev.ui.widget.FrameLayout";
        classMap["LinearLayout"] = "org.zamedev.ui.widget.LinearLayout";
        classMap["Progress"] = "org.zamedev.ui.widget.Progress";
        classMap["Radio"] = "org.zamedev.ui.widget.Radio";
        classMap["RecyclerView"] = "org.zamedev.ui.widget.RecyclerView";
        classMap["Toggle"] = "org.zamedev.ui.widget.Toggle";
    }
}
