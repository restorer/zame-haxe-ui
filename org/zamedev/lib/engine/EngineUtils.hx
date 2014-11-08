package org.zamedev.lib.engine;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.PixelSnapping;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

using org.zamedev.lib.engine.View;

class EngineUtils {
    public static function createBitmapFromAssets(id:String, pixelSnapping:PixelSnapping = null, smoothing:Bool = true):Bitmap {
        if (pixelSnapping == null) {
            pixelSnapping = PixelSnapping.AUTO;
        }

        return new Bitmap(Assets.getBitmapData(id), pixelSnapping, smoothing);
    }

    public static function createTextField(fontName:String, fontSize:Float, fontColor:UInt, text:String):TextField {
        var textField = new TextField();

        var textFormat = new TextFormat(fontName, fontSize, fontColor);
        textFormat.align = TextFormatAlign.CENTER;

        textField.width = 1000;
        textField.height = 1000;
        textField.selectable = false;
        textField.embedFonts = true;
        textField.defaultTextFormat = textFormat;
        textField.text = text;

        // textField.backgroundColor = 0x800000;
        // textField.background = true;

        #if js
            textField.width = textField.textWidth;

            if (fontSize <= 16) {
                textField.height = fontSize * 1.185;
            } else {
                textField.height = fontSize;
            }
        #else
            #if android
                textField.width = textField.textWidth * 1.1;
            #else
                textField.width = textField.textWidth + 4;
            #end

            textField.height = textField.textHeight;
        #end

        return textField;
    }

    public static function createButton(
        fontId:String,
        fontSize:Float,
        fontColor:UInt,
        text:String,
        upStateId:String,
        downStateId:String = null,
        textOffset:Point = null
    ):Button {
        if (downStateId == null) {
            downStateId = upStateId;
        }

        if (textOffset == null) {
            textOffset = new Point(0, 0);
        }

        var upState = new Sprite();
        var upStateText = createTextField(fontId, fontSize, fontColor, text);
        upState.addChild(createBitmapFromAssets(upStateId));
        upStateText.setCxy(upState.width / 2 + textOffset.x, upState.height / 2 + textOffset.y);
        upState.addChild(upStateText);

        var downState = new Sprite();
        var downStateText = createTextField(fontId, fontSize, fontColor, text);
        downState.addChild(createBitmapFromAssets(downStateId));
        downStateText.setCxy(downState.width / 2 + textOffset.x, downState.height / 2 + textOffset.y);
        downState.addChild(downStateText);

        return new Button(upState, downState);
    }
}
