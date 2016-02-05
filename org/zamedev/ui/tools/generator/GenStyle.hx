package org.zamedev.ui.tools.generator;

typedef GenStyle = {
    includeList : Array<String>,
    staticMap : Map<String, String>,
    runtimeMap : Map<String, Array<GenStyleRuntimeItem>>,
};
