package org.zamedev.ui.tools.parser;

import org.zamedev.ui.tools.generator.GenPosition;
import org.zamedev.ui.tools.generator.GenStyle;

typedef StyleSpec = {
    origName : String,
    name : String,
    includeList : Array<String>,
    genStyle : GenStyle,
    pos : GenPosition,
};
