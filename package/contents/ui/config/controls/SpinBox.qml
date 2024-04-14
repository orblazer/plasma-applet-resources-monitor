/**
 * Example:
// Integer
RMControls.SpinBox {
    from: 0
    to: 1000
    stepSize: 5
    suffix: " px"
}
// Double
RMControls.SpinBox {
    decimals: 3
    realFrom: 0.0
    realTo: 1000.0
    stepSize: decimalToInt(0.5)

    textFromValue: (value, locale) => {
        return formatValue(value, locale) + " m"
    }
}
 */
import QtQuick
import QtQuick.Controls as QQC2

// Original SpinBox: https://github.com/qt/qtdeclarative/blob/dev/src/quickcontrols/basic/SpinBox.qml
// Inspired by: https://github.com/mpaperno/maxLibQt/blob/master/src/quick/maxLibQt/controls/MLDoubleSpinBox.qm
QQC2.SpinBox {
    id: control
    editable: true
    inputMethodHints: Qt.ImhFormattedNumbersOnly

    implicitWidth: implicitBackgroundWidth + leftInset + rightInset // Don't resize spinbox if contentItem change

    readonly property int decimalFactor: Math.pow(10, decimals)

    // Custom properties
    property int decimals: 0
    property real realValue
    property real realFrom: 0
    property real realTo: Math.floor(2147483647 / decimalFactor)
    property string suffix: ""

    // Internal properties
    value: decimalToInt(realValue)
    from: decimalToInt(realFrom)
    to: decimalToInt(realTo)
    validator: DoubleValidator {
        locale: control.locale.name
        bottom: Math.min(control.realFrom, control.realTo)
        top: Math.max(control.realFrom, control.realTo)
        notation: DoubleValidator.StandardNotation
        decimals: control.decimals
    }

    Component.onCompleted: realValue = Qt.binding(() => value / decimalFactor)

    // Text format
    textFromValue: (value, locale) => formatValue(value, locale) + suffix
    valueFromText: (text, locale) => {
        text = text.replace(new RegExp(`[^\\+\\-\\d${locale.decimalPoint + locale.exponential}]`, "gi"), "");
        if (!text.length) {
            text = "0";
        }
        return Number.fromLocaleString(locale, text) * decimalFactor
    }

    contentItem: TextInput {
        z: 2
        text: control.textFromValue(control.value, control.locale)
        clip: width < implicitWidth
        selectByMouse: true

        font: control.font
        color: control.palette.text
        selectionColor: control.palette.highlight
        selectedTextColor: control.palette.highlightedText
        verticalAlignment: Qt.AlignVCenter

        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: control.inputMethodHints

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

    // Wheel/scroll action detection area
    MouseArea {
        anchors.fill: control
        z: control.contentItem.z + 1
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            var delta = (wheel.angleDelta.y === 0.0 ? -wheel.angleDelta.x : wheel.angleDelta.y) / 120;
            if (wheel.inverted) {
                delta *= -1;
            }
            control.value += stepSize * delta;
            control.focus = true;
        }
    }

    /**
     * Utils functions
     */
    function formatValue(value, locale) {
        return Number(value / decimalFactor).toLocaleString(locale, "f", decimals);
    }

    function decimalToInt(decimal) {
        return decimal * decimalFactor;
    }
}
