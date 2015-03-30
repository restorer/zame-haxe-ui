package org.zamedev.ui.tools.parser;

import org.zamedev.ui.tools.generator.GenSelector;

typedef SelectorSpec = {
    origName:String,
    name:String,
    includeList:Array<String>,
    paramMap:GenSelector,
};
