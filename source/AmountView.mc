import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

// Digit entry: xxx.xx (5 slots) or xxxx (4 slots when hideDecimal).
// UP/DOWN (or tap top/bottom zone) scrolls the active digit.
// On touchscreen: tap a digit to move focus there; swipe left to confirm.
// START advances/confirms on button devices.
// BACK clears the active digit and steps back; hold BACK resets all.
class AmountView extends WatchUi.View {
    private var _model as TallyModel;
    private var _digits as Array;        // fixed size _totalSlots; values always preserved
    private var _lockedCount as Number;  // boundary: slots 0..<_lockedCount are locked
    private var _totalSlots as Number;
    private var _decimalAfter as Number; // -1 when hideDecimal
    private var _digitCenterX as Array;  // centre-x of each slot, set in _drawDigits

    function initialize(model as TallyModel) {
        View.initialize();
        _model = model;
        _totalSlots   = model.hideDecimal ? 4 : 5;
        _decimalAfter = model.hideDecimal ? -1 : 3;
        _digitCenterX = new [_totalSlots];
        _lockedCount  = 0;
        _digits = new [_totalSlots];
        for (var i = 0; i < _totalSlots; i++) {
            _digits[i] = 0;
            _digitCenterX[i] = 0;
        }
    }

    function onLayout(dc as Graphics.Dc) as Void {}

    function onShow() as Void {
        // When returning from the next screen, reactivate the last digit for editing
        if (_lockedCount == _totalSlots) {
            _lockedCount = _totalSlots - 1;
        }
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var isTouchScreen = System.getDeviceSettings().isTouchScreen;

        if (isTouchScreen) {
            _drawArrows(dc, cx, h);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, h * 26 / 100, Graphics.FONT_TINY, "Amount",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawText(cx, h * 76 / 100, Graphics.FONT_XTINY, "swipe left = confirm",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, h * 15 / 100, Graphics.FONT_TINY, "Amount",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            var hint = (_lockedCount == _totalSlots - 1) ? "START = confirm" : "START = next";
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, h * 83 / 100, Graphics.FONT_XTINY, hint,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        _drawDigits(dc, cx, h / 2);
    }

    private function _drawArrows(dc as Graphics.Dc, cx as Number, h as Number) as Void {
        var s = h * 7 / 100;
        var t = h * 5 / 100;

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);

        var uy = h * 12 / 100;
        dc.fillPolygon([[cx, uy - t], [cx + s, uy + t], [cx - s, uy + t]]);

        var dy = h * 88 / 100;
        dc.fillPolygon([[cx, dy + t], [cx + s, dy - t], [cx - s, dy - t]]);
    }

    private function _drawDigits(dc as Graphics.Dc, cx as Number, cy as Number) as Void {
        var font = Graphics.FONT_NUMBER_HOT;
        var charDims = dc.getTextDimensions("0", font);
        var charW = charDims[0];
        var gap = 2;

        var dotW = 0;
        if (_decimalAfter >= 0) {
            var dotDims = dc.getTextDimensions(".", font);
            dotW = dotDims[0];
        }

        var totalW = _totalSlots * charW + dotW + gap * (_totalSlots + 1);
        var x = cx - totalW / 2;

        for (var i = 0; i < _totalSlots; i++) {
            if (i == _decimalAfter) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(x, cy, font, ".",
                    Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
                x += dotW + gap;
            }

            _digitCenterX[i] = x + charW / 2;

            var digit;
            var color;
            if (i < _lockedCount) {
                digit = (_digits[i] as Number).toString();
                color = Graphics.COLOR_WHITE;
            } else if (i == _lockedCount) {
                digit = (_digits[_lockedCount] as Number).toString();
                color = Graphics.COLOR_BLUE;
            } else {
                digit = (_digits[i] as Number).toString();
                color = Graphics.COLOR_DK_GRAY;
            }

            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, cy, font, digit,
                Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            x += charW + gap;
        }
    }

    function scrollUp() as Void {
        _digits[_lockedCount] = ((_digits[_lockedCount] as Number) + 1) % 10;
        WatchUi.requestUpdate();
    }

    function scrollDown() as Void {
        _digits[_lockedCount] = ((_digits[_lockedCount] as Number) - 1 + 10) % 10;
        WatchUi.requestUpdate();
    }

    function advance() as Boolean {
        if (_lockedCount >= _totalSlots) { return true; }
        _lockedCount++;
        if (_lockedCount == _totalSlots) { return true; }
        WatchUi.requestUpdate();
        return false;
    }

    // Tap a digit slot by x coordinate.
    // Tapping the active slot advances (locks it and moves focus forward).
    // Tapping any other slot moves focus there directly, preserving all stored values.
    // Returns true when the caller should navigate to the next screen.
    function focusDigit(tapX as Number) as Boolean {
        var closest = 0;
        var bestDist = (_digitCenterX[0] as Number) - tapX;
        if (bestDist < 0) { bestDist = -bestDist; }

        for (var i = 1; i < _totalSlots; i++) {
            var d = (_digitCenterX[i] as Number) - tapX;
            if (d < 0) { d = -d; }
            if (d < bestDist) { bestDist = d; closest = i; }
        }

        if (closest == _lockedCount) {
            return advance();
        }
        _lockedCount = closest;
        WatchUi.requestUpdate();
        return false;
    }

    function deleteLast() as Boolean {
        if (_lockedCount > 0) {
            _lockedCount--;
            _digits[_lockedCount] = 0;
            WatchUi.requestUpdate();
            return false;
        }
        return true;
    }

    function resetAll() as Void {
        _lockedCount = 0;
        for (var i = 0; i < _totalSlots; i++) { _digits[i] = 0; }
        WatchUi.requestUpdate();
    }

    function confirmAmount() as Void {
        _lockedCount = _totalSlots;
    }

    function parseAmount() as Float {
        if (_decimalAfter < 0) {
            var intVal = 0;
            for (var i = 0; i < _totalSlots; i++) {
                intVal = intVal * 10 + (_digits[i] as Number);
            }
            return intVal.toFloat();
        }
        var intVal = 0;
        for (var i = 0; i < _decimalAfter; i++) {
            intVal = intVal * 10 + (_digits[i] as Number);
        }
        var dec = (_digits[_decimalAfter] as Number) * 10
                + (_digits[_decimalAfter + 1] as Number);
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
        // Touchscreen input is handled entirely in onTap to avoid double-firing.
        if (System.getDeviceSettings().isTouchScreen) { return false; }
        var view = WatchUi.getCurrentView()[0] as AmountView;
        if (view.advance()) {
            _model.amount = view.parseAmount();
            pushNextAfterAmount(_model);
        }
        return true;
    }

    function onBack() as Boolean {
        var view = WatchUi.getCurrentView()[0] as AmountView;
        if (view.deleteLast()) { return false; }
        return true;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        var view = WatchUi.getCurrentView()[0] as AmountView;
        if (key == WatchUi.KEY_UP)   { view.scrollUp();   return true; }
        if (key == WatchUi.KEY_DOWN) { view.scrollDown(); return true; }
        return false;
    }

    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Boolean {
        var view = WatchUi.getCurrentView()[0] as AmountView;
        var dir = swipeEvent.getDirection();
        if (dir == WatchUi.SWIPE_UP)   { view.scrollUp();   return true; }
        if (dir == WatchUi.SWIPE_DOWN) { view.scrollDown(); return true; }
        if (dir == WatchUi.SWIPE_LEFT) {
            view.confirmAmount();
            _model.amount = view.parseAmount();
            pushNextAfterAmount(_model);
            return true;
        }
        return false;
    }

    function onHold(clickEvent as WatchUi.ClickEvent) as Boolean {
        (WatchUi.getCurrentView()[0] as AmountView).resetAll();
        return true;
    }

    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        var coords = clickEvent.getCoordinates();
        var y = coords[1];
        var screenH = System.getDeviceSettings().screenHeight;
        var view = WatchUi.getCurrentView()[0] as AmountView;

        if (y < screenH * 30 / 100) {
            view.scrollUp();
            return true;
        }
        if (y > screenH * 70 / 100) {
            view.scrollDown();
            return true;
        }
        if (view.focusDigit(coords[0])) {
            _model.amount = view.parseAmount();
            pushNextAfterAmount(_model);
        }
        return true;
    }
}
