import QtQuick 2.15
import QtQuick.Controls 2.15

import "./"

SpinBox {
    property string suffix: ''

    id: control
    validator: DoubleValidator {
        locale: control.locale.name
        bottom: Math.min(control.from, control.to)
        top: Math.max(control.from, control.to)
    }

    valueFromText: function(value, locale) {
        if (suffix.length > 0) {
            return Number.fromLocaleString(locale, value.replace(' ' + suffix, ''))
        } else {
            return Number.fromLocaleString(locale, value)
        }
    }
    textFromValue: function(value, locale) {
        return Number(value).toLocaleString(locale, 'f', 0) + (suffix.length > 0 ? ' ' + suffix : '');
    }

    contentItem: SpinBoxTextInput {
        text: control.textFromValue(control.value, control.locale)

        font: control.font
        horizontalAlignment: Qt.AlignLeft
        verticalAlignment: Qt.AlignVCenter

        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
    }
}
