import QtQuick
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
    property string title: ""
    property string titleWhen: "always" // values: always, hints, never
    property var colors: [undefined, undefined, undefined] // Common graph settings
    property var sensorsType: [] // Present because is graph settings
    property int fontSize: -1 // Present because is graph settings | See "textContainer.fontSize"

    // Minimum width of widget
    required property var sensorsFormat
    readonly property int minimumWidth: {
        if (!textContainer.enabled) {
            return 0;
        }

        let maxLength = 0;
        for (const index in sensorsType) {
            if (sensorsFormat[index] && sensorsType[index] != "none") {
                const length = Formatter.Formatter.maximumLength(sensorsFormat[index], textContainer.font);
                if (length > maxLength) {
                    maxLength = length;
                }
            }
        }
        return maxLength;
    }

    // Labels
    readonly property bool alwaysTitle: titleWhen === "always"
    RMComponents.TextContainer {
        id: textContainer
        z: 1
        valueColors: root.colors
        hintColors: root.colors
        hints: alwaysTitle ? [" ", " ", ""] : [title, "", ""]
        lineCount: alwaysTitle ? 2 : 1
        placement: "center"
        fontSize: root.fontSize

        displayment: titleWhen == "hints" ? "hover-hints" : "always"

        Component.onCompleted: {
            if (alwaysTitle) {
                getLabel(0).valueText = title;
            }
        }
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
        const value = sensor.getValue();
        textContainer.setValue(alwaysTitle ? 1 : 0, value, _formatValue(1, value));
    }

    property var _formatValue: _defaultFormatValue
    function _defaultFormatValue(index, value) {
        return Formatter.Formatter.formatValueShowNull(value, sensor.unit);
    }
}
