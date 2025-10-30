import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter
import org.kde.kirigami as Kirigami
import "../../" as RMComponents

Item {
    id: root

    // Aliases
    readonly property alias textContainer: textContainer
    readonly property alias sensor: sensor

    // Text properties
    property var colors: [undefined, undefined, undefined] // Common graph settings
    property var sensorsType: [] // Present because is graph settings

    // Thresholds properties
    property var thresholds: [] // ONLY USED FOR CONFIG (graph settings)! | See "textContainer.thresholds"

    // Labels
    RMComponents.TextContainer {
        id: textContainer
        anchors.fill: parent
        z: 1
        hintColors: root.colors
        hints: [" ", " ", ""]
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
        const value = sensor.getValue()
        textContainer.setValue(1, value, _formatValue(1, value))
    }

    property var _formatValue: _defaultFormatValue
    function _defaultFormatValue(index, value) {
        return Formatter.Formatter.formatValueShowNull(value, sensor.unit);
    }
}
