import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter
import "./base" as RMBaseGraph

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "GpuGraph"

    // Settings
    property string device: "gpu0" // Device index (eg: gpu0, gpu1)

    // Config shortcut
    readonly property bool showTemp: sensorsType[2] && device !== "all"
    readonly property var fieldInPercent: [(sensorsType[0] == "usage" || sensorsType[0].endsWith("-percent")), sensorsType[1].endsWith("-percent")]

    sensorsFormat: [(fieldInPercent[0] ? Formatter.Units.UnitPercent : Formatter.Units.UnitByte), (fieldInPercent[1] ? Formatter.Units.UnitPercent : Formatter.Units.UnitByte, Formatter.Units.UnitCelsius)]

    // Labels
    textContainer {
        valueColors: [undefined, undefined, root.colors[2]]
        thresholdIndex: 2
        thresholds: root.thresholds // No change needed, simply map it

        hints: [(sensorsType[0].includes("memory") ? "VRAM" : "GPU"), (secondChartVisible ? "VRAM" : ""), (showTemp ? i18nc("Graph label", "Temp.") : "")]
    }

    // Graph options
    secondChartVisible: sensorsType[1] !== "none"
    sensorSlots: [
        // First
        sensorsType[0].includes("memory") ? `gpu/${device}/usedVram` : `gpu/${device}/usage`,
        // Second
        secondChartVisible ? `gpu/${device}/usedVram` : null,
        // Third
        showTemp ? `gpu/${device}/temperature` : null]

    // Override methods, for handle memory in percent
    _formatValue: (index, value) => {
        if (fieldInPercent[index]) {
            return i18nc("Percent unit", "%1%", Math.round((value / root.realUplimits[index]) * 1000) / 10); // This is for round to 1 decimal
        }
        return _defaultFormatValue(index, value);
    }

    // Initialize limits and threshold
    Sensors.SensorDataModel {
        id: maxQueryModel
        sensors: [`gpu/${device}/totalVram`]
        enabled: true
        property var maxMemory: [100, -1]

        onDataChanged: topLeft => {
            // Update values
            const valueVar = parseInt(data(topLeft, Sensors.SensorDataModel.Value));
            if (isNaN(valueVar) || valueVar <= 0) {
                return;
            }

            enabled = false;
            if (sensorsType[0].includes("memory")) {
                maxMemory[0] = valueVar;
            }
            if (sensorsType[1].includes("memory")) {
                maxMemory[1] = valueVar;
            }
            root.realUplimits = maxMemory;
        }
    }
}
