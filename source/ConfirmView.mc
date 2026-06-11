import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

class ConfirmView extends WatchUi.View {
    private var _model as TallyModel;
    private var _submitting as Boolean;

    function initialize(model as TallyModel) {
        View.initialize();
        _model = model;
        _submitting = false;
    }

    function setSubmitting(v as Boolean) as Void {
        _submitting = v;
    }

    function onLayout(dc as Graphics.Dc) as Void {
        setLayout(Rez.Layouts.ConfirmLayout(dc));
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var currency = Application.getApp().getProperty("currency") as String;
        if (currency == null || currency.equals("")) { currency = "USD"; }

        var amountStr = currency + " " + _model.amount.format("%.2f");
        var noteStr = (_model.description != null && !_model.description.equals("")) ? _model.description : "-";
        var backendStr = _backendName();
        var hintStr = _submitting ? "Sending..." : "START";

        var from = (_model.accountFrom != null && !_model.accountFrom.equals("")) ? _model.accountFrom : "?";
        var accountsStr;
        if (_model.requireAccountTo) {
            var to = (_model.accountTo != null && !_model.accountTo.equals("")) ? _model.accountTo : "?";
            accountsStr = from + " > " + to;
        } else {
            accountsStr = from;
        }

        (findDrawableById("LabelAmount")   as WatchUi.Text).setText(amountStr);
        (findDrawableById("LabelCategory") as WatchUi.Text).setText(_model.category);
        (findDrawableById("LabelAccounts") as WatchUi.Text).setText(accountsStr);
        (findDrawableById("LabelNote")     as WatchUi.Text).setText(noteStr);
        (findDrawableById("LabelBackend")  as WatchUi.Text).setText(backendStr);
        (findDrawableById("LabelHint")     as WatchUi.Text).setText(hintStr);

        View.onUpdate(dc);
    }

    private function _backendName() as String {
        var target = Application.getApp().getProperty("targetApp") as Number;
        if (target == null) { target = 0; }
        var names = ["Generic Webhook", "Firefly III"];
        if (target >= 0 && target < names.size()) {
            return "> " + names[target];
        }
        return "> Unknown";
    }
}

class ConfirmDelegate extends WatchUi.BehaviorDelegate {
    private var _model as TallyModel;

    function initialize(model as TallyModel) {
        BehaviorDelegate.initialize();
        _model = model;
    }

    function onSelect() as Boolean {
        var views = WatchUi.getCurrentView();
        var view = views[0] as ConfirmView;
        view.setSubmitting(true);
        WatchUi.requestUpdate();
        HttpClient.submit(_model, method(:onHttpResult));
        return true;
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onHttpResult(responseCode as Number, data) as Void {
        var dataType = "null";
        if (data instanceof String)     { dataType = "String"; }
        else if (data instanceof Dictionary) { dataType = "Dictionary"; }
        else if (data instanceof Number){ dataType = "Number"; }
        System.println("TALLY response code=" + responseCode + " dataType=" + dataType);
        if (data instanceof Dictionary) {
            System.println("TALLY data keys=" + (data as Dictionary).keys().toString());
        } else if (data instanceof String) {
            var s = data as String;
            System.println("TALLY data=" + (s.length() > 200 ? s.substring(0, 200) : s));
        }

        var success = (responseCode / 100 == 2) || (responseCode == -400);
        var msg;
        if (success) {
            msg = (responseCode == -400) ? "Sent!" : "Logged!";
            Application.Storage.setValue("lastAmount",   _model.amount.format("%.2f"));
            Application.Storage.setValue("lastCategory", _model.category);
        } else if (responseCode == 0 && data instanceof String) {
            msg = data as String;
        } else {
            msg = responseCode.toString() + ": " + _extractError(data);
        }
        WatchUi.pushView(
            new ResultView(success, msg),
            new ResultDelegate(),
            WatchUi.SLIDE_UP
        );
    }

    private function _extractError(data) as String {
        if (data instanceof Dictionary) {
            var d = data as Dictionary;
            if (d.hasKey("message")) {
                var m = d["message"];
                if (m instanceof String) { return m as String; }
            }
            if (d.hasKey("errors")) {
                var e = d["errors"];
                if (e instanceof String) { return e as String; }
            }
            return "server error";
        }
        if (data instanceof String) {
            var s = data as String;
            return s.length() > 80 ? s.substring(0, 80) : s;
        }
        return "no detail";
    }
}
