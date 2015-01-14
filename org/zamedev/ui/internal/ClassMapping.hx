package org.zamedev.ui.internal;

class ClassMapping {
    public static var classMap:Map<String, String>;

    static function __init__() {
        classMap = new Map<String, String>();

        classMap["ImageView"] = Type.getClassName(org.zamedev.ui.view.ImageView);
        classMap["Rect"] = Type.getClassName(org.zamedev.ui.view.Rect);
        classMap["SpaceView"] = Type.getClassName(org.zamedev.ui.view.SpaceView);
        classMap["TextView"] = Type.getClassName(org.zamedev.ui.view.TextView);
        classMap["View"] = Type.getClassName(org.zamedev.ui.view.View);
        classMap["AbsoluteLayout"] = Type.getClassName(org.zamedev.ui.widget.AbsoluteLayout);
        classMap["Button"] = Type.getClassName(org.zamedev.ui.widget.Button);
        classMap["FrameLayout"] = Type.getClassName(org.zamedev.ui.widget.FrameLayout);
        classMap["LinearLayout"] = Type.getClassName(org.zamedev.ui.widget.LinearLayout);
        classMap["Progress"] = Type.getClassName(org.zamedev.ui.widget.Progress);
        classMap["Radio"] = Type.getClassName(org.zamedev.ui.widget.Radio);
        classMap["RecyclerView"] = Type.getClassName(org.zamedev.ui.widget.RecyclerView);
        classMap["Toggle"] = Type.getClassName(org.zamedev.ui.widget.Toggle);
    }
}
