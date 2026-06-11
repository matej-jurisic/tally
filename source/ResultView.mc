import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Timer;
import Toybox.Lang;

class ResultView extends WatchUi.View {
    private var _success as Boolean;
    private var _message as String;
    private var _model as TallyModel;
    private var _timer as Timer.Timer?;

    function initialize(success as Boolean, message as String, model as TallyModel) {
        View.initialize();
        _success = success;
        _message = message;
        _model = model;
        _timer = null;
    }

    function onShow() as Void {
        _timer = new Timer.Timer();
        _timer.start(method(:onTimer), 3000, false);
    }

    function onHide() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    function onTimer() as Void {
        _returnToStart();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var bg = _success ? Graphics.COLOR_DK_GREEN : Graphics.COLOR_RED;
        dc.setColor(Graphics.COLOR_WHITE, bg);
        dc.clear();
        var cx = dc.getWidth() / 2;
        var cy = dc.getHeight() / 2;
        if (_success) {
            dc.drawText(cx, cy, Graphics.FONT_LARGE, _message,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            var colon = -1;
            for (var i = 0; i < _message.length(); i++) {
                if (_message.substring(i, i + 2).equals(": ")) { colon = i; break; }
            }
            if (colon > 0) {
                dc.drawText(cx, cy - dc.getHeight() / 8, Graphics.FONT_MEDIUM,
                    _message.substring(0, colon),
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
                dc.drawText(cx, cy + dc.getHeight() / 8, Graphics.FONT_XTINY,
                    _message.substring(colon + 2, _message.length()),
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            } else {
                dc.drawText(cx, cy, Graphics.FONT_SMALL, _message,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        }
    }

    function returnToStart() as Void {
        _returnToStart();
    }

    private function _returnToStart() as Void {
        var model = new TallyModel();
        WatchUi.switchToView(
            new AmountView(model),
            new AmountDelegate(model),
            WatchUi.SLIDE_DOWN
        );
    }
}

class ResultDelegate extends WatchUi.BehaviorDelegate {
    private var _view as ResultView;

    function initialize(view as ResultView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        _view.returnToStart();
        return true;
    }
}
