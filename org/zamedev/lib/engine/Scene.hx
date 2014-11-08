package org.zamedev.lib.engine;

using Lambda;

class Scene extends Layer {
	private var layers:List<Layer>;

	@:generic
	private function addLayer<T:Layer>(layer:T):T {
		layers.add(layer);
		addChild(layer);

		return layer;
	}

	override public function create():Void {
		super.create();
		layers = new List<Layer>();
	}

	override public function init():Void {
		super.init();

		layers.iter(function(layer) {
			layer.init();
		});
	}

	override public function update(dt:Float):Void {
		super.update(dt);

		layers.iter(function(layer) {
			layer.update(dt);
		});
	}

	override public function render():Void {
		super.render();

		layers.iter(function(layer) {
			layer.render();
		});
	}

	override public function resize():Void {
		super.resize();

		layers.iter(function(layer) {
			layer.resize();
		});
	}
}
