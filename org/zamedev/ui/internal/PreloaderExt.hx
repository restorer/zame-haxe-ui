package org.zamedev.ui.internal;

import openfl.display.Preloader;

#if (js && html5)

import js.Browser;

class PreloaderExt extends Preloader {
    override private function loadFont (font:String):Void {
        var node = Browser.document.createElement("span");
        node.innerHTML = "giItT1WQy@!-/#";

        var style = node.style;
        style.position = "absolute";
        style.left = "-10000px";
        style.top = "-10000px";
        style.fontSize = "300px";
        style.fontFamily = "sans-serif";
        style.fontVariant = "normal";
        style.fontStyle = "normal";
        style.fontWeight = "normal";
        style.letterSpacing = "0";

        Browser.document.body.appendChild(node);

        var width = node.offsetWidth;
        var interval:Null<Int> = null;
        var found = false;

        style.fontFamily = "'" + font + "', sans-serif";

        var checkFont = function () {
            if (node.offsetWidth != width) {
                // Test font was still not available yet, try waiting one more interval?
                if (!found) {
                    found = true;
                    return false;
                }

                loaded++;

                if (interval != null) {
                    Browser.window.clearInterval(interval);
                }

                node.parentNode.removeChild(node);
                node = null;

                update(loaded, total);

                if (loaded == total) {
                    start();
                }

                return true;
            }

            return false;
        }

        if (!checkFont()) {
            interval = Browser.window.setInterval(checkFont, 50);
        }
    }
}

#else

typedef PreloaderExt = Preloader;

#end
