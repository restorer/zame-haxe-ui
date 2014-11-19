package org.zamedev.ui.graphics;

enum Dimension {
    MATCH_PARENT;
    WRAP_CONTENT;
    EXACT(size:Float);
    PERCENT(weight:Float);
    WEIGHT(weight:Float);
}
