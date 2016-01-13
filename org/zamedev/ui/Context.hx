package org.zamedev.ui;

import org.zamedev.ui.internal.ApplicationStage;
import org.zamedev.ui.res.Configuration;
import org.zamedev.ui.res.Inflater;
import org.zamedev.ui.res.ResourceManager;

interface Context {
    public var application(get, null) : Application;
    public var applicationStage(get, null) : ApplicationStage;
    public var configuration(get, set) : Configuration;
    public var resourceManager(get, null) : ResourceManager;
    public var inflater(get, null) : Inflater;
}
