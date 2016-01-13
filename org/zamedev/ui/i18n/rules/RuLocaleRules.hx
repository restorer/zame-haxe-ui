package org.zamedev.ui.i18n.rules;

import org.zamedev.ui.i18n.LocaleRules;
import org.zamedev.ui.i18n.Quantity;

/*
 * Locale data: http://www.unicode.org/cldr/
 *
 * Copyright © 1991-2007 Unicode, Inc. All rights reserved.
 * Distributed under the Terms of Use in http://www.unicode.org/copyright.html.
*/

class RuLocaleRules implements LocaleRules {
    public function new() {
    }

    /*
    <pluralRule count="one">v = 0 and i % 10 = 1 and i % 100 != 11</pluralRule>
    <pluralRule count="few">v = 0 and i % 10 = 2..4 and i % 100 != 12..14</pluralRule>
    <pluralRule count="many">v = 0 and i % 10 = 0 or v = 0 and i % 10 = 5..9 or v = 0 and i % 100 = 11..14</pluralRule>
    <pluralRule count="other"></pluralRule>
    */

    public function getQuantityForFloat(n : Float) : Quantity {
        if (n % 10 == 1 && n % 100 != 11) {
            return Quantity.ONE;
        } else if (Std.int(n) == n && n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 12 || n % 100 > 14)) {
            return Quantity.TWO;
        } else if (n % 10 == 0 || (Std.int(n) == n && n % 10 >= 5 && n % 10 <= 9) || (Std.int(n) == n && n % 100 >= 11 && n % 100 <= 14)) {
            return Quantity.MANY;
        } else {
            return Quantity.OTHER;
        }
    }
}
