package org.zamedev.ui.graphics;

enum Dimension {
    MATCH_PARENT;
    WRAP_CONTENT;
    EXACT(size : Float);
    WEIGHT_PARENT(weight : Float, type : DimensionType, useWeightSum : Bool);
    WEIGHT_STAGE(weight : Float, type : DimensionType, useWeightSum : Bool);
}
