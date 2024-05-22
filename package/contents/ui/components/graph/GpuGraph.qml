import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.sensors as Sensors
import "./base" as RMBaseGraph

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "GpuGraph"

    // Settings
    property string device: "gpu0" // Device index (eg: gpu0, gpu1)

    // Config shortcut
    property bool memoryInPercent: sensorsType[0].endsWith("-percent")
    property bool showTemp: sensorsType[1] && device !== "all"

    // Labels
    thresholdIndex: 2
    realThresholds: thresholds // No change needed, simply map it
    textContainer {
        valueColors: [undefined, undefined, root.colors[2]]

        hints: ["GPU", (secondChartVisible ? "VRAM" : ""), (showTemp ? i18nc("Graph label", "Temp.") : "")]
    }

    // Graph options
    realUplimits: maxQueryModel.maxMemory
    sensorsModel.sensors: {
        let sensors = [`gpu/${device}/usage`, `gpu/${device}/usedVram`];
        if (showTemp) {
            sensors.push(`gpu/${device}/temperature`);
        }
        return sensors;
    }
    secondChartVisible: sensorsType[0] !== "none"

    // Override methods, for handle memeory in percent
    _formatValue: (index, value) => {
        if (index === 1 && memoryInPercent) {
            return i18nc("Percent unit", "%1%", Math.round((value / maxQueryModel.maxMemory[1]) * 1000) / 10); // This is for round to 1 decimal
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
            maxMemory = [100, valueVar]
        }
    }
}
