<?php

class TexmapGenerator {
	const WIDTH = 1024;
	const HEIGHT = 1024;

	public $img = null;
	protected $rows = array();
	protected $cols = array();
	protected $free = array(array());
	protected $images = array();

	protected function tryToFit($r, $c, $w, $h) {
		$rs = 0;
		$fh = 0;

		do {
			$rs += 1;

			if ($r + $rs > count($this->rows)) {
				return null;
			}

			$cs = 0;
			$fw = 0;

			do {
				$cs += 1;

				if (($c + $cs > count($this->cols)) || !$this->free[$r + $rs - 1][$c + $cs - 1]) {
					return null;
				}

				$fw += $this->cols[$c + $cs - 1]['w'];
			} while ($fw < $w);

			$fh += $this->rows[$r + $rs - 1]['h'];
		} while ($fh < $h);

		return array('r' => $r, 'c' => $c, 'rs' => $rs, 'cs' => $cs, 'fh' => $fh, 'fw' => $fw, 'area' => $fh * $fw);
	}

	protected function getAndSplitRegion($w, $h) {
		$result = null;

		for ($r = 0; $r < count($this->rows); $r++) {
			for ($c = 0; $c < count($this->cols); $c++) {
				$current = $this->tryToFit($r, $c, $w, $h);

				if ($current != null && ($result == null || $result['area'] > $current['area'])) {
					$result = $current;
				}

				if ($current != null) {
					$result = $current;
					break;
				}
			}
		}

		if ($result == null) {
			return null;
		}

		if ($result['fw'] != $w) {
			$nw = $result['fw'] - $w;
			$col = $result['c'] + $result['cs'] - 1;
			$this->cols[$col]['w'] -= $nw;

			array_splice($this->cols, $col + 1, 0, array(array(
				'x' => $this->cols[$col]['x'] + $this->cols[$col]['w'],
				'w' => $nw,
			)));

			for ($r = 0; $r < count($this->rows); $r++) {
				array_splice($this->free[$r], $col + 1, 0, array($this->free[$r][$col]));
			}
		}

		if ($result['fh'] != $h) {
			$nh = $result['fh'] - $h;
			$row = $result['r'] + $result['rs'] - 1;
			$this->rows[$row]['h'] -= $nh;

			array_splice($this->rows, $row + 1, 0, array(array(
				'y' => $this->rows[$row]['y'] + $this->rows[$row]['h'],
				'h' => $nh,
			)));

			array_splice($this->free, $row + 1, 0, array($this->free[$row]));
		}

		for ($r = 0; $r < $result['rs']; $r++) {
			for ($c = 0; $c < $result['cs']; $c++) {
				$this->free[$result['r'] + $r][$result['c'] + $c] = false;
			}
		}

		return array(
			'x' => $this->cols[$result['c']]['x'],
			'y' => $this->rows[$result['r']]['y'],
		);
	}

	protected function cmpBySizeDesc($a, $b) {
		$sizeA = $a['w'] * $a['h'];
		$sizeB = $b['w'] * $b['h'];

		return ($sizeA == $sizeB ? 0 : ($sizeA > $sizeB ? -1 : 1));
	}

	protected function generatePart($resImageName) {
		if ($this->img != null) {
			imageDestroy($this->img);
		}

		$this->img = imageCreateTrueColor(self::WIDTH, self::HEIGHT);
		imageSaveAlpha($this->img, true);
		imageFill($this->img, 0, 0, imageColorAllocateAlpha($this->img, 0, 0, 0, 127));

		$this->rows = array(
			array('y' => 1, 'h' => self::HEIGHT - 1),
		);

		$this->cols = array(
			array('x' => 1, 'w' => self::WIDTH - 1),
		);

		$this->free = array(
			array(true),
		);

		$data = array();
		$nextRoundImages = array();

		foreach ($this->images as $idx => $item) {
			if ($item['w'] == 1) {
				$region = $this->getAndSplitRegion($item['w'] + 3, $item['h'] + 1);
			} else {
				$region = $this->getAndSplitRegion($item['w'] + 1, $item['h'] + 1);
			}

			if (!$region) {
				// echo "{$item['name']}: Can't find region!\n";
				// imagePNG($this->img, $resImageName);
				// return;

				$nextRoundImages[] = $item;
				continue;
			}

			$this->images[$idx]['x'] = $region['x'];
			$this->images[$idx]['y'] = $region['y'];

			if ($item['w'] == 1) {
				imageCopy($this->img, $item['img'], $region['x'], $region['y'], 0, 0, $item['w'], $item['h']);
				imageCopy($this->img, $item['img'], $region['x'] + 1, $region['y'], 0, 0, $item['w'], $item['h']);
				imageCopy($this->img, $item['img'], $region['x'] + 2, $region['y'], 0, 0, $item['w'], $item['h']);

				$data[$item['name']] = array(
					'x' => $region['x'] + 1,
					'y' => $region['y'],
					'w' => $item['w'],
					'h' => $item['h'],
				);
			} else {
				imageCopy($this->img, $item['img'], $region['x'], $region['y'], 0, 0, $item['w'], $item['h']);

				$data[$item['name']] = array(
					'x' => $region['x'],
					'y' => $region['y'],
					'w' => $item['w'],
					'h' => $item['h'],
				);
			}

			echo "{$item['name']}: {$region['x']}f, {$region['y']}f, {$item['w']}f, {$item['h']}f\n";
		}

		imagePNG($this->img, $resImageName);

		$this->images = $nextRoundImages;
		return $data;
	}

	public function generate($fromDir, $toDir, $resXmlName, $packedDrawablePrefix) {
		$this->images = array();
		$dh = @opendir($fromDir);

		if ($dh === false) {
			echo "Can't open \"${fromDir}\"\n";
			return;
		}

		while (($name = readdir($dh)) !== false) {
			if (!preg_match('/\.png$/i', $name)) {
				continue;
			}

			$size = getImageSize($fromDir . '/' . $name);

			if ($size[0] > (self::WIDTH - 2) || $size[1] > (self::HEIGHT - 2)) {
				echo "Image \"{$name}\" is too big\n";
				return;
			}

			$this->images[] = array(
				'name' => preg_replace('/\.png$/i', '', $name),
				'img' => imageCreateFromPNG($fromDir . '/' . $name),
				'w' => $size[0],
				'h' => $size[1]
			);
		}

		closedir($dh);
		usort($this->images, array($this, 'cmpBySizeDesc'));

		$index = 1;
		$dataMap = array();

		while (count($this->images)) {
			$packedDrawableName = $packedDrawablePrefix . $index;
			$dataMap[$packedDrawableName] = $this->generatePart("{$toDir}/{$packedDrawableName}.png");
			$index++;
		}

		$resData = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<resources>\n";

		foreach ($dataMap as $packedDrawableName => $data) {
			foreach ($data as $name => $item) {
				$resData .= "    <drawable name=\"{$name}\">\n"
					. "        <packed drawable=\"@drawable/{$packedDrawableName}\""
					. " x=\"{$item['x']}\""
					. " y=\"{$item['y']}\""
					. " w=\"{$item['w']}\""
					. " h=\"{$item['h']}\" />\n"
					. "    </drawable>\n";
			}
		}

		$resData .= "</resources>\n";
		file_put_contents($resXmlName, $resData);
	}
}

$gen = new TexmapGenerator();

$gen->generate(
	__DIR__ . '/drawable-parts',
	__DIR__ . '/../assets/drawable',
	__DIR__ . '/../assets/resource/drawable.xml',
	'packed_'
);
