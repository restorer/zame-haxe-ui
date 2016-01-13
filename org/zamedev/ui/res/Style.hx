package org.zamedev.ui.res;

import org.zamedev.ui.view.View;

typedef Style = {
    staticFunc : View -> ResourceManager -> Void,
    runtimeFunc : View -> Map<String, Bool> -> ResourceManager -> Void,
};
