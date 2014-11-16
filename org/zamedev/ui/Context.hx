package org.zamedev.ui;

import org.zamedev.ui.res.ResourceManager;

interface Context {
    public var locale(get, set):String;
    public var resourceManager(get, null):ResourceManager;
}
