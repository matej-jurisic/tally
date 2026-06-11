import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Lang;

// Generic reusable Menu2 picker.
// id values: -1 = none, -2 = custom, >= 0 = list index
class PickerView extends WatchUi.Menu2 {
    function initialize(title, items as Array, noneLabel as String, allowCustom as Boolean) {
        Menu2.initialize({:title => title});
        if (!noneLabel.equals("")) {
            addItem(new WatchUi.MenuItem(noneLabel, null, -1, {}));
        }
        for (var i = 0; i < items.size(); i++) {
            addItem(new WatchUi.MenuItem(items[i], null, i, {}));
        }
        if (allowCustom) {
            addItem(new WatchUi.MenuItem("Custom...", null, -2, {}));
        }
    }
}

class PickerDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id == -2) {
            onCustom();
        } else {
            onPicked(id == -1 ? "" : item.getLabel());
        }
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onPicked(value as String) as Void {}
    function onCustom() as Void {}
}

// --- Flow helpers ---

function pushNextAfterAmount(model as TallyModel) as Void {
    if (model.requireCategory) {
        WatchUi.pushView(
            new PickerView(Rez.Strings.LabelCategory, model.categories, "", model.allowCustomCategory),
            new CategoryDelegate(model),
            WatchUi.SLIDE_LEFT
        );
    } else {
        pushNextAfterCategory(model);
    }
}

// After category (or when it is skipped).
function pushNextAfterCategory(model as TallyModel) as Void {
    WatchUi.pushView(
        new PickerView(Rez.Strings.LabelAccountFrom, model.accountsFrom, "", model.allowCustomAccountFrom),
        new AccountFromDelegate(model),
        WatchUi.SLIDE_LEFT
    );
}

// After account-from is set (shared by picker and text-picker paths).
function pushNextAfterAccountFrom(model as TallyModel) as Void {
    if (model.requireAccountTo) {
        WatchUi.pushView(
            new PickerView(Rez.Strings.LabelAccountTo, model.accountsTo, "", model.allowCustomAccountTo),
            new AccountToDelegate(model),
            WatchUi.SLIDE_LEFT
        );
    } else {
        pushNextAfterAccountTo(model);
    }
}

// After account-to is set (or when it is skipped).
function pushNextAfterAccountTo(model as TallyModel) as Void {
    if (model.requireDescription) {
        var noneLabel = (model.descriptionDefault.length() > 0) ? model.descriptionDefault : "--- none ---";
        WatchUi.pushView(
            new PickerView(Rez.Strings.LabelDescription, model.descriptions, noneLabel, model.allowCustomDescription),
            new DescriptionDelegate(model),
            WatchUi.SLIDE_LEFT
        );
    } else {
        WatchUi.pushView(
            new ConfirmView(model),
            new ConfirmDelegate(model),
            WatchUi.SLIDE_LEFT
        );
    }
}

// --- Category ---

class CategoryDelegate extends PickerDelegate {
    private var _model as TallyModel;
    function initialize(model as TallyModel) {
        PickerDelegate.initialize();
        _model = model;
    }
    function onPicked(value as String) as Void {
        _model.category = value;
        pushNextAfterCategory(_model);
    }
}

// --- Account From ---

class AccountFromDelegate extends PickerDelegate {
    private var _model as TallyModel;
    function initialize(model as TallyModel) {
        PickerDelegate.initialize();
        _model = model;
    }
    function onPicked(value as String) as Void {
        _model.accountFrom = value;
        pushNextAfterAccountFrom(_model);
    }
    function onCustom() as Void {
        WatchUi.pushView(
            new WatchUi.TextPicker(""),
            new AccountFromTextDelegate(_model),
            WatchUi.SLIDE_LEFT
        );
    }
}

class AccountFromTextDelegate extends WatchUi.TextPickerDelegate {
    private var _model as TallyModel;
    private var _timer as Timer.Timer?;
    function initialize(model as TallyModel) {
        TextPickerDelegate.initialize();
        _model = model;
        _timer = null;
    }
    function onTextEntered(text as String, changed as Boolean) as Boolean {
        if (text != null && !text.equals("")) {
            _model.accountFrom = text;
            _timer = new Timer.Timer();
            _timer.start(method(:_pushNext), 50, false);
        }
        return true;
    }
    function _pushNext() as Void {
        pushNextAfterAccountFrom(_model);
    }
    function onCancel() as Boolean { return true; }
}

// --- Account To ---

class AccountToDelegate extends PickerDelegate {
    private var _model as TallyModel;
    function initialize(model as TallyModel) {
        PickerDelegate.initialize();
        _model = model;
    }
    function onPicked(value as String) as Void {
        _model.accountTo = value;
        pushNextAfterAccountTo(_model);
    }
    function onCustom() as Void {
        WatchUi.pushView(
            new WatchUi.TextPicker(""),
            new AccountToTextDelegate(_model),
            WatchUi.SLIDE_LEFT
        );
    }
}

class AccountToTextDelegate extends WatchUi.TextPickerDelegate {
    private var _model as TallyModel;
    private var _timer as Timer.Timer?;
    function initialize(model as TallyModel) {
        TextPickerDelegate.initialize();
        _model = model;
        _timer = null;
    }
    function onTextEntered(text as String, changed as Boolean) as Boolean {
        if (text != null && !text.equals("")) {
            _model.accountTo = text;
            _timer = new Timer.Timer();
            _timer.start(method(:_pushNext), 50, false);
        }
        return true;
    }
    function _pushNext() as Void {
        pushNextAfterAccountTo(_model);
    }
    function onCancel() as Boolean { return true; }
}

// --- Description ---

class DescriptionDelegate extends PickerDelegate {
    private var _model as TallyModel;
    function initialize(model as TallyModel) {
        PickerDelegate.initialize();
        _model = model;
    }
    function onPicked(value as String) as Void {
        _model.description = value.equals("") ? _model.descriptionDefault : value;
        WatchUi.pushView(
            new ConfirmView(_model),
            new ConfirmDelegate(_model),
            WatchUi.SLIDE_LEFT
        );
    }
    function onCustom() as Void {
        WatchUi.pushView(
            new WatchUi.TextPicker(""),
            new DescriptionTextDelegate(_model),
            WatchUi.SLIDE_LEFT
        );
    }
}

class DescriptionTextDelegate extends WatchUi.TextPickerDelegate {
    private var _model as TallyModel;
    private var _timer as Timer.Timer?;
    function initialize(model as TallyModel) {
        TextPickerDelegate.initialize();
        _model = model;
        _timer = null;
    }
    function onTextEntered(text as String, changed as Boolean) as Boolean {
        if (text != null && !text.equals("")) {
            _model.description = text;
            _timer = new Timer.Timer();
            _timer.start(method(:_pushNext), 50, false);
        }
        return true;
    }
    function _pushNext() as Void {
        WatchUi.pushView(
            new ConfirmView(_model),
            new ConfirmDelegate(_model),
            WatchUi.SLIDE_LEFT
        );
    }
    function onCancel() as Boolean { return true; }
}
