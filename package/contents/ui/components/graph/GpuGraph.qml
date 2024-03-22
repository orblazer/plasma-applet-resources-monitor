import QtQuick 2.15
import org.kde.plasma.plasmoid 2.0
import org.kde.ksysguard.sensors 1.0 as Sensors
import "./base" as RMBaseGraph
import "../functions.js" as Functions

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "GpuGraph"

    // Config options
    property color temperatureColor: Functions.getColor("gpuTemperatureColor")

    // Bind config changes
    Connections {
        target: plasmoid.configuration
        function onGpuIndexChanged() {
            maxQueryModel.enabled = true
        }
    }

    // Labels
    thresholds: [undefined, undefined, [plasmoid.configuration.thresholdWarningGpuTemp, plasmoid.configuration.thresholdCriticalGpuTemp]]

    textContainer {
        labelColors: [root.colors[0], root.colors[1], temperatureColor]
        valueColors: [undefined, undefined, temperatureColor]

        labels: ["GPU", (secondChartVisible ? "VRAM" : ""), (plasmoid.configuration.showGpuTemperature ? i18nc("Graph label", "Temp.") : "")]
    }

    // Graph options
    // NOTE: "sensorsModel.sensors" set from "maxQueryModel"
    colors: [Functions.getColor("gpuColor"), Functions.getColor("gpuMemoryColor")]
    secondChartVisible: plasmoid.configuration.gpuMemoryGraph

    // Override methods, for handle memeory in percent
    _formatValue: (index, data) => {
        if (index === 1 && plasmoid.configuration.gpuMemoryInPercent) {
            return i18nc("Percent unit", "%1%", Math.round((data.value / maxQueryModel.maxMemory) * 1000) / 10); // This is for round to 1 decimal
        }
        return _defaultFormatValue(index, data);
    }

    // Initialize limits and threshold
    Sensors.SensorDataModel {
        id: maxQueryModel
        sensors: ["gpu/" + plasmoid.configuration.gpuIndex + "/totalVram"]
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
            const gpu = plasmoid.configuration.gpuIndex
            root.sensorsModel.sensors = ["gpu/" + gpu + "/usage", "gpu/" + gpu + "/usedVram", "gpu/" + gpu + "/temperature"];
        }
    }
}
