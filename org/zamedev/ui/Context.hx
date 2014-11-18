package org.zamedev.ui;

import org.zamedev.ui.internal.RootSprite;
import org.zamedev.ui.res.ResourceManager;

interface Context {
    public var rootSprite(get, null):RootSprite;
    public var locale(get, set):String;
    public var resourceManager(get, null):ResourceManager;
}
