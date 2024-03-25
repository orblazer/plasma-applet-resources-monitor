import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.sensors as Sensors
import "./base" as RMBaseGraph

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "GpuGraph"

    // Settings
    property string gpuIndex: "" // Gpu sensor index (eg: gpu0, gpu1)

    // Config shortcut
    property bool memoryInPercent: sensorsType[0].endsWith("-percent")

    // Labels
    thresholdIndex: 2
    realThresholds: thresholds // No change needed, simply map it
    textContainer {
        valueColors: [undefined, undefined, root.colors[2]]

        labels: ["GPU", (secondChartVisible ? "VRAM" : ""), (sensorsType[1] ? i18nc("Graph label", "Temp.") : "")]
    }

    // Graph options
    // NOTE: "sensorsModel.sensors" set from "maxQueryModel"
    secondChartVisible: sensorsType[0] !== "none"

    // Override methods, for handle memeory in percent
    _formatValue: (index, data) => {
        if (index === 1 && memoryInPercent) {
            return i18nc("Percent unit", "%1%", Math.round((data.value / maxQueryModel.maxMemory) * 1000) / 10); // This is for round to 1 decimal
        }
        return _defaultFormatValue(index, data);
    }

    // Initialize limits and threshold
    Sensors.SensorDataModel {
        id: maxQueryModel
        sensors: [`gpu/${gpuIndex}/totalVram`]
        enabled: true
        property int maxMemory: -1

        onDataChanged: {
            // Update values
            const valueVar = parseInt(data(topLeft, Sensors.SensorDataModel.Value));
            if (isNaN(valueVar) || valueVar <= 0) {
                return;
            }
            enabled = false;
            maxMemory = valueVar;

            // Update graph Y range
            root.uplimits = [100, maxMemory];

            // Update sensors
            root.sensorsModel.sensors = [`gpu/${gpuIndex}/usage`, `gpu/${gpuIndex}/usedVram`, `gpu/${gpuIndex}/temperature`];
        }
    }
}
