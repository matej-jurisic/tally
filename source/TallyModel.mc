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

    function initialize() {
        amount = 0.0f;
        category = "";
        description = "";
        accountFrom = "";
        accountTo = "";
        categories  = _parseProperty("categories",   "Uncategorized");
        descriptions = _parseProperty("description", "");
        accountsFrom = _parseProperty("accountsFrom", "");
        accountsTo   = _parseProperty("accountsTo",   "");
        requireAccountTo = Application.getApp().getProperty("requireAccountTo") as Boolean;
        if (requireAccountTo == null) { requireAccountTo = true; }
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
