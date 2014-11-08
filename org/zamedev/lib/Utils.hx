package org.zamedev.lib;

class Utils {
	@:generic
	public static function createArray<T>(length:Int, def:T):Array<T> {
		return [for (i in 0 ... length) def];
	}

	@:generic
	public static function createArray2d<T>(rows:Int, cols:Int, def:T):Array<Array<T>> {
		return [for (i in 0 ... rows) [for (j in 0 ... cols) def]];
	}
}
