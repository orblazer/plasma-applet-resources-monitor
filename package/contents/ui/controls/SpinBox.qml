/**
 * Example:
import "./components/controls" as RMControls
// Integer
RMControls.SpinBox {
    from: 0
    to: 1000
    stepSize: 5

    textFromValue: function(value, locale) {
        return valueToText(value, locale) + " px"
    }
}
// Double
RMControls.SpinBox {
    decimals: 3
    minimumValue: 0.0
    maximumValue: 1000.0
    stepSize: Math.round(0.5 * factor)

    textFromValue: function(value, locale) {
        return valueToText(value, locale) + " m"
    }
}
 */
import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.plasma.core 2.0 as PlasmaCore

QQC2.SpinBox {
    id: control
    editable: true

    readonly property real factor: Math.pow(10, decimals)
    readonly property int spinBox_MININT: Math.ceil(-2147483648 / factor)
    readonly property int spinBox_MAXINT: Math.floor(2147483647 / factor)

    value: Math.round(realValue * factor)
    from: Math.round(minimumValue * factor)
    to: Math.round(maximumValue * factor)

    // Copry from https://doc.qt.io/qt-5/qml-qtquick-controls2-spinbox.html#custom-values
    property int decimals: 0
    property real realValue

    property real minimumValue: 0
    property real maximumValue: spinBox_MAXINT

    // Bind "realValue" to "value" and "factor"
    Component.onCompleted: {
        realValue = Qt.binding(() => value / factor);
    }

    validator: DoubleValidator {
        locale: control.locale.name
        bottom: Math.min(control.from, control.to)
        top: Math.max(control.from, control.to)
    }

    textFromValue: valueToText
    valueFromText: (text, locale) => {
        text = text.replace(/[^\-\.\d]/g, ""); // Remove non digit characters
        if (text === ".") {
            text = "0";
        }
        return Number.fromLocaleString(locale, text) * factor;
    }

    property var valueToText: (value, locale) => {
        // "toLocaleString" has no concept of "the minimum amount of
        // digits to represent this number", so we need to calculate this
        // manually. This ensures that things like "0" and "10" will be
        // displayed without any decimals, while things like "2.2" and
        // "3.87" will be displayed with the right number of decimals.
        const realValue = Number(value / factor);
        return realValue.toLocaleString(locale, 'f', countDecimals(realValue));
    }

    contentItem: TextInput {
        opacity: enabled ? 1 : 0.5
        text: control.displayText
        font: control.font
        color: PlasmaCore.Theme.viewTextColor
        selectionColor: PlasmaCore.Theme.highlightColor
        selectedTextColor: PlasmaCore.Theme.highlightedTextColor
        verticalAlignment: Qt.AlignVCenter
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: control.inputMethodHints
        selectByMouse: true

        // Accept return/enter key
        Keys.onReturnPressed: returnPressed = true
        Keys.onEnterPressed: returnPressed = true

        // Reselect field when validate value with "return"
        property bool returnPressed
        onTextChanged: {
            if (returnPressed) {
                returnPressed = false;
                selectAll();
            }
        }
    }

    // Allow cancel editing
    Keys.onEscapePressed: {
        contentItem.text = textFromValue(value, locale.name);
        focus = false;
    }

    // Select value on foucs
    onActiveFocusChanged: {
        if (activeFocus) {
            contentItem.selectAll();
        }
    }

    function countDecimals(value) {
        if (Math.floor(value) === value) {
            return 0;
        }
        return value.toString().split(".")[1].length || 0;
    }
}
