import QtQuick 2.2
import QtQuick.Controls 2.15

SpinBox {
    property string suffix: ''

    id: spinbox
    validator: DoubleValidator {
        bottom: Math.min(spinbox.from, spinbox.to)
        top: Math.max(spinbox.from, spinbox.to)
    }

    textFromValue: function(value, locale) {
        return Number.fromLocaleString(locale, value) + (suffix.length > 0 ? ' ' + suffix : '');
    }
}
