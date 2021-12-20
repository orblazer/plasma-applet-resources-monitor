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
import QtQuick 2.0
import QtQuick.Controls 2.0 as QQC2

QQC2.SpinBox {
    id: spinBox

    editable: true

    readonly property real factor: Math.pow(10, decimals)
    property real valueReal: value / factor
    value: Math.round(valueReal * factor)

    readonly property int spinBox_MININT: Math.ceil(-2147483648 / factor)
    readonly property int spinBox_MAXINT: Math.floor(2147483647 / factor)
    from: Math.round(minimumValue * factor)
    to: Math.round(maximumValue * factor)

    onValueChanged: {
        valueReal = value / factor
    }

    // Reimplement QQC1 properties
    // https://github.com/qt/qtquickcontrols/blob/dev/src/controls/SpinBox.qml
    property int decimals: 0
    property real minimumValue: 0
    property real maximumValue: spinBox_MAXINT

    validator: DoubleValidator {
        locale: spinBox.locale.name
        bottom: minimumValue
        top: maximumValue
    }

    textFromValue: valueToText
    valueFromText: function(text, locale) {
        var text2 = text
            .replace(/[^\-\.\d]/g, "") // Remove non digit characters
            .replace(/\.+/g, ".") // Allow user to type "." instead of RightArrow to enter to decimals
        return Number.fromLocaleString(locale, text2) * factor
    }

    function valueToText(value, locale) {
        // "toLocaleString" has no concept of "the minimum amount of
        // digits to represent this number", so we need to calculate this
        // manually. This ensures that things like "0" and "10" will be
        // displayed without any decimals, while things like "2.2" and
        // "3.87" will be displayed with the right number of decimals.

        let realValue = Number(value / factor)
        return realValue.toLocaleString(locale, 'f', countDecimals(realValue))
    }

    // Select value on foucs
    onActiveFocusChanged: {
        if (activeFocus) {
            selectValue()
        }
    }
    function selectValue() {
        // Check if SpinBox.contentItem == TextInput
        // https://invent.kde.org/frameworks/qqc2-desktop-style/-/blob/master/org.kde.desktop/SpinBox.qml
        // https://doc.qt.io/qt-5/qml-qtquick-textinput.html#select-method
        if (contentItem && contentItem instanceof TextInput) {
            contentItem.selectAll()
        }
    }

    function fixMinus(str) {
        var minusIndex = str.indexOf("-")
        if (minusIndex >= 0) {
            var a = str.substr(0, minusIndex)
            var b = str.substr(minusIndex+1)
            return "-" + a + b
        } else {
            return str
        }
    }
    function fixDecimals(str) {
        var periodIndex = str.indexOf(".")
        var a = str.substr(0, periodIndex+1)
        var b = str.substr(periodIndex+1)
        return a + b.replace(/\.+/g, "") // Remove extra periods
    }

    function fixText(str) {
        return fixMinus(fixDecimals(str))
    }

    function countDecimals(value) {
        if(Math.floor(value) === value) return 0;
        return value.toString().split(".")[1].length || 0;
    }

    function onTextEdited() {
        var oldText = spinBox.contentItem.text
        oldText = fixText(oldText)
        var oldPeriodIndex = oldText.indexOf(".")
        if (oldPeriodIndex == -1) {
            oldPeriodIndex = oldText.length
        }
        var oldCursorPosition = spinBox.contentItem.cursorPosition
        var oldCursorDelta = oldPeriodIndex - oldCursorPosition

        spinBox.value = spinBox.valueFromText(oldText, spinBox.locale)
        spinBox.valueModified()

        var newText = spinBox.contentItem.text
        newText = fixText(newText)
        var newPeriodIndex = newText.indexOf(".")
        if (newPeriodIndex == -1) {
            newPeriodIndex = newText.length
        }
        if (newText != spinBox.contentItem.text) {
            spinBox.contentItem.text = Qt.binding(function(){
                return spinBox.textFromValue(spinBox.value, spinBox.locale)
            })
        }
        spinBox.contentItem.cursorPosition = newPeriodIndex - oldCursorDelta
    }

    function bindContentItem() {
        if (contentItem && contentItem instanceof TextInput) {
            // Bind value update on keypress, while retaining cursor position
            spinBox.contentItem.textEdited.connect(spinBox.onTextEdited)

            // Align text to left
            spinBox.contentItem.horizontalAlignment = TextInput.AlignLeft
        }
    }

    onContentItemChanged: {
        bindContentItem()
    }

    Component.onCompleted: {
        for (var i = 0; i < data.length; i++) {
            if (data[i] instanceof Connections) {
                // Remove the Connections where it changes the text/cursor when typing.
                // onTextEdited { value = valueFromText() }
                data[i].destroy()
                break
            }
        }
        bindContentItem()
    }
}
