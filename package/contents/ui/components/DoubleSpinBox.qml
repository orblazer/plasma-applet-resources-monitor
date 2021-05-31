import QtQuick 2.2
import QtQuick.Controls 2.15

SpinBox {
    property int decimals: 2
    property real realValue: 0.0
    property real realFrom: 0.0
    property real realTo: 100.0
    property real realStepSize: 1.0
    property string suffix: ''

    property real _factor: Math.pow(10, decimals)

    id: spinbox
    stepSize: realStepSize * _factor
    value: realValue * _factor
    from: realFrom * _factor
    to: realTo * _factor
    validator: DoubleValidator {
        bottom: Math.min(spinbox.from, spinbox.to) * spinbox._factor
        top: Math.max(spinbox.from, spinbox.to) * spinbox._factor
    }

    textFromValue: function(value, locale) {
        return parseFloat(value * 1.0 / _factor).toFixed(decimals) + (suffix.length > 0 ? ' ' + suffix : '');
    }
}
