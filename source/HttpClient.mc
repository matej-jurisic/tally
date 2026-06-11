import Toybox.Application;
import Toybox.Communications;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Lang;

module HttpClient {

    function submit(model as TallyModel, callback as Method) as Void {
        var app = Application.getApp();
        var target = app.getProperty("targetApp") as Number;
        var baseUrl = app.getProperty("webhookUrl") as String;
        var token = app.getProperty("authToken") as String;

        if (target == null) { target = 0; }

        if (baseUrl == null || baseUrl.equals("")) {
            callback.invoke(0, "No URL set");
            return;
        }

        var url = "";
        var body = {};
        var headers = {};

        switch (target) {
            case 1: // Firefly III
                if (token == null || token.equals("")) {
                    callback.invoke(0, "No token set");
                    return;
                }
                url = baseUrl + "/api/v1/transactions";
                body = _buildFirefly(model, app);
                headers = _bearerHeaders(token);
                break;
            default: // Generic Webhook (0)
                url = baseUrl;
                body = _buildGeneric(model, app);
                headers = {};
                break;
        }

        System.println("TALLY url=" + url);
        Communications.makeWebRequest(
            url,
            body,
            {
                :method => Communications.HTTP_REQUEST_METHOD_POST,
                :headers => headers,
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            },
            callback
        );
    }

    function _buildGeneric(model as TallyModel, app as Application.AppBase) as Dictionary {
        var currency = app.getProperty("currency") as String;
        if (currency == null || currency.equals("")) { currency = "USD"; }
        return {
            "schema"       => "v1",
            "amount"       => model.amount,
            "category"     => model.category,
            "note"         => model.description,
            "account_from" => model.accountFrom,
            "account_to"   => model.accountTo,
            "currency"     => currency,
            "timestamp"    => _isoTimestamp()
        };
    }

    function _buildFirefly(model as TallyModel, app as Application.AppBase) as Dictionary {
        var currency = app.getProperty("currency") as String;
        if (currency == null || currency.equals("")) { currency = "USD"; }

        var desc = (model.description != null && !model.description.equals(""))
            ? model.description
            : "Expense";

        var body = {
            "transactions[0][type]"          => "withdrawal",
            "transactions[0][date]"          => _isoTimestamp(),
            "transactions[0][amount]"        => model.amount.format("%.2f"),
            "transactions[0][description]"   => desc,
            "transactions[0][currency_code]" => currency
        };
        if (model.category != null && !model.category.equals("")) {
            body["transactions[0][category_name]"] = model.category;
        }
        if (model.accountFrom != null && !model.accountFrom.equals("")) {
            var fromId = model.accountFrom.toNumber();
            if (fromId != null) { body["transactions[0][source_id]"]   = fromId; }
            else                { body["transactions[0][source_name]"] = model.accountFrom; }
        }
        if (model.accountTo != null && !model.accountTo.equals("")) {
            var toId = model.accountTo.toNumber();
            if (toId != null) { body["transactions[0][destination_id]"]   = toId; }
            else              { body["transactions[0][destination_name]"] = model.accountTo; }
        }
        return body;
    }

    function _bearerHeaders(token as String) as Dictionary {
        return {
            "Authorization" => "Bearer " + token,
            "Accept"        => "application/json"
        };
    }

    function _todayDate() as String {
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        return info.year.toString() + "-" + _pad(info.month) + "-" + _pad(info.day);
    }

    function _isoTimestamp() as String {
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        return info.year.toString() + "-"
             + _pad(info.month) + "-"
             + _pad(info.day) + "T"
             + _pad(info.hour) + ":"
             + _pad(info.min) + ":"
             + _pad(info.sec) + "Z";
    }

    function _pad(n as Number) as String {
        return (n < 10) ? ("0" + n.toString()) : n.toString();
    }
}
