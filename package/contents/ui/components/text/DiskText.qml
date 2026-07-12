import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter
import "./base" as RMBase

RMBase.BaseSensorText {
    id: root
    objectName: "DiskText"
    sensorsFormat: [fieldInPercent ? Formatter.Units.UnitPercent : Formatter.Units.UnitByte]

    // Settings
    property string device: "all" // Device ID (e.g.: "sda" or "sdc"); could be "all"

    // Config shortcut
    property var fieldInPercent: sensorsType[0].endsWith("-percent")

    // Value options - use used sensor to get disk usage
    sensor.sensorId: `disk/${device}/used`

    // Text options
    textContainer {
        displayment: "always"
        valueColors: root.colors

        Component.onCompleted: {
            textContainer.getLabel(0).valueText = "Disk"
        }
    }

    // Initialize limits and threshold
    Sensors.Sensor {
        id: totalQuery
        sensorId: `disk/${device}/total`
        enabled: true
        property var maxDisk: -1

        onValueChanged: {
            // Update values
            const val = parseInt(value);
            if (isNaN(val) || val <= 0) {
                return;
            }
            maxDisk = val;
            enabled = false;
        }
    }

    // Override methods, for handle disk in percent
    _formatValue: (index, value) => {
        if (fieldInPercent) {
            return i18nc("Percent unit", "%1%", Math.round((value / totalQuery.maxDisk) * 1000) / 10); // This is for round to 1 decimal
        }
        return _defaultFormatValue(index, value);
    }
}
