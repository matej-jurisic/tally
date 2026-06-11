import Toybox.Application;
import Toybox.Lang;

class TallyModel {
    var amount as Float;
    var category as String;
    var description as String;
    var accountFrom as String;
    var accountTo as String;
    var categories as Array;
    var descriptions as Array;
    var accountsFrom as Array;
    var accountsTo as Array;
    var requireAccountTo as Boolean;
    var requireCategory as Boolean;
    var requireDescription as Boolean;
    var hideDecimal as Boolean;
    var allowCustomCategory as Boolean;
    var allowCustomAccountFrom as Boolean;
    var allowCustomAccountTo as Boolean;
    var allowCustomDescription as Boolean;
    var descriptionDefault as String;

    function initialize() {
        amount = 0.0f;
        category = "";
        description = "";
        accountFrom = "";
        accountTo = "";
        categories    = _parseProperty("categories",   "Uncategorized");
        descriptions  = _parseProperty("description",  "");
        accountsFrom  = _parseProperty("accountsFrom", "");
        accountsTo    = _parseProperty("accountsTo",   "");
        var app = Application.getApp();
        requireAccountTo  = _bool(app.getProperty("requireAccountTo"),  true);
        requireCategory   = _bool(app.getProperty("requireCategory"),   true);
        requireDescription = _bool(app.getProperty("requireDescription"), true);
        hideDecimal            = _bool(app.getProperty("hideDecimal"),            false);
        allowCustomCategory    = _bool(app.getProperty("allowCustomCategory"),    false);
        allowCustomAccountFrom = _bool(app.getProperty("allowCustomAccountFrom"), true);
        allowCustomAccountTo   = _bool(app.getProperty("allowCustomAccountTo"),   true);
        allowCustomDescription = _bool(app.getProperty("allowCustomDescription"), false);
        var dd = app.getProperty("descriptionDefault") as String;
        descriptionDefault = (dd != null) ? dd : "";
    }

    private function _bool(val as Boolean, fallback as Boolean) as Boolean {
        return (val != null) ? val : fallback;
    }

    private function _parseProperty(key as String, fallback as String) as Array {
        var raw = Application.getApp().getProperty(key) as String;
        if (raw == null || raw.equals("")) {
            return fallback.equals("") ? [] : [fallback];
        }
        var result = [];
        var start = 0;
        var len = raw.length();
        for (var i = 0; i <= len; i++) {
            if (i == len || raw.substring(i, i + 1).equals(",")) {
                if (i > start) {
                    var part = raw.substring(start, i);
                    while (part.length() > 0 && part.substring(0, 1).equals(" ")) {
                        part = part.substring(1, part.length());
                    }
                    while (part.length() > 0 && part.substring(part.length() - 1, part.length()).equals(" ")) {
                        part = part.substring(0, part.length() - 1);
                    }
                    if (part.length() > 0) {
                        result.add(part);
                    }
                }
                start = i + 1;
            }
        }
        return result.size() > 0 ? result : (fallback.equals("") ? [] : [fallback]);
    }
}
