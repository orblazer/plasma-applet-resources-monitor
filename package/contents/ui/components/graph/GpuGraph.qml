import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.sensors as Sensors
import "./base" as RMBaseGraph
import "../functions.mjs" as Functions

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "GpuGraph"

    // Config options
    property color temperatureColor: Functions.resolveColor(Plasmoid.configuration.gpuTemperatureColor)
    property bool memoryInPercent: Plasmoid.configuration.gpuMemoryUnit.endsWith("-percent")

    // Bind config changes
    Connections {
        target: Plasmoid.configuration
        function onGpuIndexChanged() {
            maxQueryModel.enabled = true
        }
    }

    // Labels
    thresholds: [undefined, undefined, [Plasmoid.configuration.thresholdWarningGpuTemp, Plasmoid.configuration.thresholdCriticalGpuTemp]]

    textContainer {
        labelColors: [root.colors[0], root.colors[1], temperatureColor]
        valueColors: [undefined, undefined, temperatureColor]

        labels: ["GPU", (secondChartVisible ? "VRAM" : ""), (Plasmoid.configuration.showGpuTemperature ? i18nc("Graph label", "Temp.") : "")]
    }

    // Graph options
    // NOTE: "sensorsModel.sensors" set from "maxQueryModel"
    colors: [Functions.resolveColor(Plasmoid.configuration.gpuColor), Functions.resolveColor(Plasmoid.configuration.gpuMemoryColor)]
    secondChartVisible: Plasmoid.configuration.gpuMemoryUnit !== "none"

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
        sensors: ["gpu/" + Plasmoid.configuration.gpuIndex + "/totalVram"]
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
            const gpu = Plasmoid.configuration.gpuIndex
            root.sensorsModel.sensors = ["gpu/" + gpu + "/usage", "gpu/" + gpu + "/usedVram", "gpu/" + gpu + "/temperature"];
        }
    }
}
