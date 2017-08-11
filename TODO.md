http://lib.haxe.org/p/xmlTools

drawable - ссылка на другой drawable, e.g. <drawable name="bbb">@drawable/aaa</drawable>

Программные drawable (в xml описывать по слоям что и где рисовать).
Так же было бы круто чтоб можно было делать новые drawable на основе старых + фильтр (alpha / color overlay / перекрашивание / etc),
Тогда можно было бы ложить в ресурсы только одну картинку (например, чёрного цвета), а все остальные получать перекрашиванием.

На обдумывание: в андроиде plurals "понимают" : zero, one, two, few, many, и other, в ICU MessageFormat для js только one, few, many и other, в ICU MessageFormat для PHP то же что и в JS, только two === few (по крайней мере для русского).
