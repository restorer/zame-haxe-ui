package org.zamedev.ui;

class Application extends ContextWrapper {
    public function new() {
        super();
        context = new ApplicationContext();
    }
}
