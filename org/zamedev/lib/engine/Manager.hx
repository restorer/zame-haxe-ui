package org.zamedev.lib.engine;

import openfl.Lib;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl.display.FPS;

using Lambda;

class Manager extends Scene {
	private var appWidth:Float;
	private var appHeight:Float;
	private var prevTime:Int = -1;
	private var currentScene:Scene = null;
	private var scenes:List<Scene>;

	#if debug
		private var fps:FPS;
	#end

	public function new(appWidth:Float, appHeight:Float) {
		super(null);
		manager = this;

		this.appWidth = appWidth;
		this.appHeight = appHeight;

		#if flash
			var rect:Shape = new Shape();
			rect.graphics.beginFill(0xFFFFFF);
			rect.graphics.drawRect(0, 0, appWidth, appHeight);
			rect.graphics.endFill();
			addChild(rect);

			this.mask = rect;
		#end

		create();
		init();
		start();

		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		stage.addEventListener(Event.RESIZE, onStageResize);
	}

	#if !flash override #end private function get_width():Float {
		return appWidth;
	}

	#if !flash override #end private function set_width(value:Float):Float {
		if (appWidth != value) {
			appWidth = value;
			onStageResize(null);
		}

		return value;
	}

	#if !flash override #end private function get_height():Float {
		return appHeight;
	}

	#if !flash override #end private function set_height(value:Float):Float {
		if (appHeight != value) {
			appHeight = value;
			onStageResize(null);
		}

		return value;
	}

	@:generic
	private function addScene<T:Scene>(scene:T):T {
		scenes.add(scene);
		return scene;
	}

	override public function create():Void {
		super.create();
		scenes = new List<Scene>();
	}

	override public function init():Void {
		super.init();
		onStageResize(null);

		#if debug
			fps = new FPS(10, 10, 0xFF0000);
			addChild(fps);
		#end

		scenes.iter(function(scene) {
			scene.init();
		});
	}

	private function start():Void {
	}

	public function changeScene(scene:Scene):Void {
		#if debug
			if (fps.stage != null) {
				removeChild(fps);
			}
		#end

		if (currentScene != null && currentScene.stage != null) {
			removeChild(currentScene);
		}

		currentScene = scene;
		addChild(currentScene);

		#if debug
			addChild(fps);
		#end
	}

	override public function update(dt:Float):Void {
		super.update(dt);

		if (currentScene != null) {
			currentScene.update(dt);
		}
	}

	override public function render():Void {
		super.render();

		if (currentScene != null) {
			currentScene.render();
		}
	}

	private function onEnterFrame(event:Event):Void {
		var dt:Float;

		if (prevTime < 0) {
			prevTime = Lib.getTimer();
			dt = 0.0;
		} else {
			var currentTime = Lib.getTimer();
			dt = (currentTime - prevTime) / 1000.0;
			prevTime = currentTime;
		}

		if (dt > 10.0) {
			dt = 10.0;
		}

		while (dt > 0.0) {
			update(dt);
			dt -= 1.0;
		}

		render();
	}

	override public function resize():Void {
		super.resize();

		if (currentScene != null) {
			currentScene.resize();
		}
	}

	private function onStageResize(event:Event):Void {
		if (stage.stageWidth < 1 || stage.stageHeight < 1 || appWidth < 1 || appHeight < 1) {
			x = 0;
			y = 0;
			scaleX = 0;
			scaleY = 0;
		} else {
			var desiredRatio = appWidth / appHeight;
			var stageRatio = stage.stageWidth / stage.stageHeight;
			var scale:Float;

			if (stageRatio < desiredRatio) {
				scale = stage.stageWidth / appWidth;
				y = Math.round((stage.stageHeight - appHeight * scale) / 2);
				x = 0;
			} else {
				scale = stage.stageHeight / appHeight;
				x = Math.fround((stage.stageWidth - appWidth * scale) / 2);
				y = 0;
			}

			scaleX = scale;
			scaleY = scale;
		}

		resize();
	}
}
