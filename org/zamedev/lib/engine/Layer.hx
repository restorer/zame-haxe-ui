package org.zamedev.lib.engine;

import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Matrix;

class Layer extends Sprite {
	private var manager:Manager;
	private var sharedMatrix:Matrix;

	public function new(manager:Manager) {
		super();

		this.manager = manager;

		if (manager != null) {
			create();
		}
	}

	@:generic
	private function addSprite<T:Sprite>(sprite:T):T {
		addChild(sprite);
		return sprite;
	}

	public function create():Void {
	}

	public function init():Void {
		sharedMatrix = new Matrix();
	}

	public function update(dt:Float):Void {
	}

	public function render():Void {
	}

	public function resize():Void {
	}

	// Expects that sharedMatrix is empty
	private function drawBitmapRect(bitmapData:BitmapData, x:Float, y:Float, width:Float, height:Float):Void {
		sharedMatrix.tx = x;
		sharedMatrix.ty = y;

		graphics.beginBitmapFill(bitmapData, sharedMatrix, false, true);
		graphics.drawRect(x, y, width, height);
	}
}
