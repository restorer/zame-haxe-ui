package org.zamedev.ui.i18n.rules;

import org.zamedev.ui.i18n.LocaleRules;
import org.zamedev.ui.i18n.Quantity;

/*
 * Locale data: http://www.unicode.org/cldr/
 *
 * Copyright © 1991-2007 Unicode, Inc. All rights reserved.
 * Distributed under the Terms of Use in http://www.unicode.org/copyright.html.
*/

class EnLocaleRules implements LocaleRules {
    public function new() {
    }

    /*
    <pluralRule count="one">i = 1 and v = 0</pluralRule>
    <pluralRule count="other"></pluralRule>
    */

    public function getQuantityForFloat(n : Float) : Quantity {
        if (n == 1) {
            return Quantity.ONE;
        } else {
            return Quantity.TWO;
        }
    }
}
