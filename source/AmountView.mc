import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

// 5-slot digit entry: xxx.xx (max 999.99)
// UP/DOWN scrolls the active digit 0-9.
// START locks the active digit and advances; on the 5th slot it confirms.
// BACK deletes the last locked digit.
// Active digit is shown in blue; locked digits white; future digits dark gray.
class AmountView extends WatchUi.View {
    private var _model as TallyModel;
    private var _digits as Array;   // locked digits, each 0-9
    private var _active as Number;  // current scrolling value for the next slot

    private const TOTAL_SLOTS = 5;
    private const DECIMAL_AFTER = 3; // decimal point goes between slot 2 and slot 3

    function initialize(model as TallyModel) {
        View.initialize();
        _model = model;
        _digits = [];
        _active = 0;
    }

    function onLayout(dc as Graphics.Dc) as Void {
        // No layout XML — fully programmatic
    }

    // Called when view reappears (e.g. BACK from category picker).
    // Restore the last locked digit to active so the slot is editable again.
    function onShow() as Void {
        if (_digits.size() == TOTAL_SLOTS) {
            _active = _digits[TOTAL_SLOTS - 1] as Number;
            _digits = _digits.slice(0, TOTAL_SLOTS - 1);
        }
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        // Title
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 15 / 100, Graphics.FONT_TINY, "Amount",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        _drawDigits(dc, cx, h / 2);

        // Hint
        var hint = (_digits.size() == TOTAL_SLOTS - 1) ? "START = confirm" : "START = next";
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 83 / 100, Graphics.FONT_XTINY, hint,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function _drawDigits(dc as Graphics.Dc, cx as Number, cy as Number) as Void {
        var font = Graphics.FONT_NUMBER_HOT;
        var charDims = dc.getTextDimensions("0", font);
        var charW = charDims[0];
        var dotDims = dc.getTextDimensions(".", font);
        var dotW = dotDims[0];
        var gap = 2;

        // Total pixel width of "xxx.xx"
        var totalW = TOTAL_SLOTS * charW + dotW + gap * (TOTAL_SLOTS + 1);
        var x = cx - totalW / 2;

        for (var i = 0; i < TOTAL_SLOTS; i++) {
            if (i == DECIMAL_AFTER) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(x, cy, font, ".",
                    Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
                x += dotW + gap;
            }

            var digit;
            var color;
            if (i < _digits.size()) {
                digit = _digits[i].toString();
                color = Graphics.COLOR_WHITE;
            } else if (i == _digits.size()) {
                digit = _active.toString();
                color = Graphics.COLOR_BLUE;
            } else {
                digit = "0";
                color = Graphics.COLOR_DK_GRAY;
            }

            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, cy, font, digit,
                Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            x += charW + gap;
        }
    }

    function scrollUp() as Void {
        _active = (_active + 1) % 10;
        WatchUi.requestUpdate();
    }

    function scrollDown() as Void {
        _active = (_active - 1 + 10) % 10;
        WatchUi.requestUpdate();
    }

    // Lock active digit and advance. Returns true when all 5 slots are filled.
    function advance() as Boolean {
        if (_digits.size() >= TOTAL_SLOTS) { return true; }
        _digits.add(_active);
        _active = 0;
        if (_digits.size() == TOTAL_SLOTS) {
            return true;
        }
        WatchUi.requestUpdate();
        return false;
    }

    // Delete last locked digit. Returns true if buffer is now fully empty.
    function deleteLast() as Boolean {
        if (_digits.size() > 0) {
            _digits = _digits.slice(0, _digits.size() - 1);
            _active = 0;
            WatchUi.requestUpdate();
            return false;
        }
        return true;
    }

    function parseAmount() as Float {
        var intVal = 0;
        for (var i = 0; i < DECIMAL_AFTER; i++) {
            intVal = intVal * 10 + (_digits[i] as Number);
        }
        var dec = (_digits[DECIMAL_AFTER] as Number) * 10
                + (_digits[DECIMAL_AFTER + 1] as Number);
        return intVal.toFloat() + dec.toFloat() / 100.0f;
    }
}

class AmountDelegate extends WatchUi.BehaviorDelegate {
    private var _model as TallyModel;

    function initialize(model as TallyModel) {
        BehaviorDelegate.initialize();
        _model = model;
    }

    function onSelect() as Boolean {
        var view = WatchUi.getCurrentView()[0] as AmountView;
        if (view.advance()) {
            _model.amount = view.parseAmount();
            WatchUi.pushView(
                new PickerView(Rez.Strings.LabelCategory, _model.categories, false, false),
                new CategoryDelegate(_model),
                WatchUi.SLIDE_LEFT
            );
        }
        return true;
    }

    function onBack() as Boolean {
        var view = WatchUi.getCurrentView()[0] as AmountView;
        if (view.deleteLast()) {
            return false; // empty — let system exit the widget
        }
        return true;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        var view = WatchUi.getCurrentView()[0] as AmountView;
        if (key == WatchUi.KEY_UP) {
            view.scrollUp();
            return true;
        }
        if (key == WatchUi.KEY_DOWN) {
            view.scrollDown();
            return true;
        }
        return false;
    }

    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Boolean {
        var view = WatchUi.getCurrentView()[0] as AmountView;
        var dir = swipeEvent.getDirection();
        if (dir == WatchUi.SWIPE_UP) {
            view.scrollUp();
            return true;
        }
        if (dir == WatchUi.SWIPE_DOWN) {
            view.scrollDown();
            return true;
        }
        return false;
    }

    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        var view = WatchUi.getCurrentView()[0] as AmountView;
        if (view.advance()) {
            _model.amount = view.parseAmount();
            WatchUi.pushView(
                new PickerView(Rez.Strings.LabelCategory, _model.categories, false, false),
                new CategoryDelegate(_model),
                WatchUi.SLIDE_LEFT
            );
        }
        return true;
    }
}
