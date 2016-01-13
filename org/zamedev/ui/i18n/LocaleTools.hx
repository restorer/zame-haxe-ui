package org.zamedev.ui.i18n;

import org.zamedev.ui.i18n.rules.EnLocaleRules;
import org.zamedev.ui.i18n.rules.RuLocaleRules;

// http://www.unicode.org/cldr/
// http://www.unicode.org/reports/tr35/tr35-numbers.html#Language_Plural_Rules

class LocaleTools {
    public static function rulesForLocale(locale : String) : LocaleRules {
        if (locale == "ru") {
            return new RuLocaleRules();
        } else {
            return new EnLocaleRules();
        }
    }
}
