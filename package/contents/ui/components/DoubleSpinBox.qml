import QtQuick 2.2
import QtQuick.Controls 2.12

import "./"

SpinBox {
    property int decimals: 2
    property real realValue: 0.0
    property real realFrom: 0.0
    property real realTo: 100.0
    property real realStepSize: 1.0
    property string suffix: ''

    property real _factor: Math.pow(10, decimals)

    id: control
    stepSize: realStepSize * _factor
    value: realValue * _factor
    from: realFrom * _factor
    to: realTo * _factor
    validator: DoubleValidator {
        locale: control.locale.name
        bottom: Math.min(control.from, control.to) * control._factor
        top: Math.max(control.from, control.to) * control._factor
    }

    onValueChanged: {
        realValue = value / _factor
    }

    valueFromText: function(value, locale) {
        if (suffix.length > 0) {
            return Number.fromLocaleString(locale, value.replace(' ' + suffix, '')) * _factor
        } else {
            return Number.fromLocaleString(locale, value) * _factor
        }
    }
    textFromValue: function(value, locale) {
        return parseFloat(value / _factor).toLocaleString(locale, 'f', decimals) + (suffix.length > 0 ? ' ' + suffix : '');
    }

    contentItem: SpinBoxTextInput {
        z: 2
        text: control.textFromValue(control.value, control.locale)

        font: control.font
        horizontalAlignment: Qt.AlignLeft
        verticalAlignment: Qt.AlignVCenter

        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
    }
}
