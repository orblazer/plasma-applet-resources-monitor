import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.sensors as Sensors
import "./base" as RMBase

RMBase.BaseSensorText {
    id: root
    objectName: "MemoryText"

    // Config shortcut
    property var fieldInPercent: sensorsType[0].endsWith("-percent")

    // Value options
    sensor.sensorId: {
        const info = sensorsType[0].split("-");
        const type = info[0] === "physical" ? "used" : "application";

        return "memory/physical/" + type;
    }

    // Text options
    textContainer {
        displayment: "always"
        firstLine.text: "RAM"
        valueColors: root.colors
    }

    // Override methods, for handle memory in percent
    _formatValue: (index, value) => {
        if (fieldInPercent) {
            return i18nc("Percent unit", "%1%", Math.round((value / maxQuery.maxMemory) * 1000) / 10); // This is for round to 1 decimal
        }
        return _defaultFormatValue(index, value);
    }

    // Initialize limits and threshold
    Sensors.Sensor {
        id: maxQuery
        sensorId: "memory/physical/total"
        enabled: true
        property var maxMemory: -1

        onValueChanged: {
            // Update values
            const val = parseInt(value);
            if (isNaN(val) || val <= 0) {
                return;
            }
            maxMemory = val;
            enabled = false;
        }
    }
}
