import QtQuick
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter
import "./base" as RMBase

RMBase.BaseSensorText {
    id: root
    objectName: "GpuText"

    sensor.sensorId: isTemperature ? `gpu/${device}/temperature` : (isMemory ? `gpu/${device}/usedVram` : `gpu/${device}/usage`)
    sensorsFormat: [fieldInPercent ? Formatter.Units.UnitPercent : Formatter.Units.UnitByte]

    // Settings
    property string device: "gpu0" // Device index (eg: gpu0, gpu1)

    readonly property bool isMemory: sensorsType[0].includes("memory")
    readonly property bool isTemperature: sensorsType[0] === "temperature"
    readonly property bool fieldInPercent: sensorsType[0] == "usage" || isMemory

    // Override methods, for handle memory in percent
    _formatValue: (index, value) => {
        if (sensorsType[0] == "memory-percent") {
            return i18nc("Percent unit", "%1%", Math.round((value / totalQuery.maxMemory) * 1000) / 10); // This is for round to 1 decimal
        }
        return _defaultFormatValue(index, value);
    }

    // Initialize limits
    Sensors.Sensor {
        id: totalQuery
        sensorId: `gpu/${device}/totalVram`
        enabled: sensorsType[0] == "memory-percent"
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
