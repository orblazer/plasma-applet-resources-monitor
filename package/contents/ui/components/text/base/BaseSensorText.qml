import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter
import org.kde.kirigami as Kirigami

Item {
    id: root

    // Aliases
    readonly property alias textContainer: textContainer
    readonly property alias sensor: sensor

    // Text properties
    property var colors: [undefined, undefined] // Common graph settings
    property var sensorsType: [] // Present because is graph settings

    // Thresholds properties
    property int thresholdIndex: -1 // Sensor index used for threshold
    property var thresholds: [] // ONLY USED FOR CONFIG (graph settings)! | See "realThresholds"
    property var realThresholds: [] // format: [warning, critical]
    readonly property color thresholdWarningColor: textContainer._resolveColor(Plasmoid.configuration.warningColor)
    readonly property color thresholdCriticalColor: textContainer._resolveColor(Plasmoid.configuration.criticalColor)

    // Labels
    TextContainer {
        id: textContainer
        anchors.fill: parent
        z: 1
        hintColors: root.colors

        onShowValues: _update()
    }

    // Retrieve data from sensors, and update labels
    Sensors.Sensor {
        id: sensor
        enabled: root.enabled
        updateRateLimit: -1

        function getValue() {
            if (value !== 0) {
                return value;
            }
            return null;
        }
    }

    // Process functions
    property var _update: _defaultUpdate
    function _defaultUpdate() {
        _updateLabel(1, sensor.getValue())
    }

    function _updateLabel(index, value) {
        // Retrieve label need to update and data
        const label = textContainer.getLabel(index);
        if (typeof label === "undefined" || !label.enabled) {
            return;
        }

        // Handle threshold value
        if (index === thresholdIndex && realThresholds.length > 0) {
            if (value >= realThresholds[1]) {
                label.color = thresholdCriticalColor;
            } else if (value >= realThresholds[0]) {
                label.color = thresholdWarningColor;
            } else {
                label.color = textContainer.getTextColor(index);
            }
        }

        // Show value on label
        label.text = _formatValue(index, value);
        label.visible = true;
    }

    property var _formatValue: _defaultFormatValue
    function _defaultFormatValue(index, value) {
        return Formatter.Formatter.formatValueShowNull(value, sensor.unit);
    }
}
