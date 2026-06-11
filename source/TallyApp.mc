import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application.Storage;

class TallyApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getGlanceView() as [WatchUi.GlanceView] or [WatchUi.GlanceView, WatchUi.GlanceViewDelegate] or Null {
        return [new TallyGlanceView()];
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        var model = new TallyModel();
        return [new AmountView(model), new AmountDelegate(model)];
    }
}

function getApp() as TallyApp {
    return Application.getApp() as TallyApp;
}

class TallyGlanceView extends WatchUi.GlanceView {
    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var cx = dc.getWidth() / 2;
        var cy = dc.getHeight() / 2;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var amount   = Storage.getValue("lastAmount")   as String?;
        var category = Storage.getValue("lastCategory") as String?;

        if (amount != null) {
            var currency = Application.getApp().getProperty("currency") as String?;
            if (currency == null || currency.equals("")) { currency = "€"; }

            dc.drawText(cx, cy - 14, Graphics.FONT_MEDIUM,
                currency + " " + amount,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            var cat = (category != null && !(category as String).equals("")) ? category as String : "Expense";
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy + 6, Graphics.FONT_XTINY,
                "last: " + cat,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            var ts = Storage.getValue("lastTimestamp") as String?;
            if (ts != null) {
                dc.drawText(cx, cy + 22, Graphics.FONT_XTINY,
                    ts as String,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        } else {
            dc.drawText(cx, cy, Graphics.FONT_MEDIUM, "Tally",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }
}
