package org.zamedev.ui.internal;

class ClassMapping {
    public static var classMap:Map<String, String>;

    static {
        classMap = new Map<String, String>();

        classMap["View"] = "org.zamedev.ui.view.View";
        classMap["ImageView"] = "org.zamedev.ui.view.ImageView";
        classMap["TextView"] = "org.zamedev.ui.view.TextView";

        classMap["Button"] = "org.zamedev.ui.widget.Button";
    }
}
