import QtQuick
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter
import "./base" as RMBase

RMBase.BaseSensorText {
    id: root
    objectName: "MemoryText"
    sensorsFormat: [fieldInPercent ? Formatter.Units.UnitPercent : Formatter.Units.UnitByte]

    // Config shortcut
    property bool isSwap: sensorsType[0].startsWith("swap")
    property var fieldInPercent: sensorsType[0].endsWith("-percent")

    // Value options
    sensor.sensorId: {
        const [type, percent] = sensorsType[0].split("-");

        switch (type) {
        case "physical":
            return "memory/physical/used";
        case "application":
            return "memory/physical/application";
        case "swap":
            return "memory/swap/used";
        }
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
        sensorId: isSwap ? "memory/swap/total" : "memory/physical/total"
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
