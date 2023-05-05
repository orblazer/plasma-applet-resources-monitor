import QtQuick 2.9
import org.kde.plasma.plasmoid 2.0
import org.kde.ksysguard.sensors 1.0 as Sensors
import "./base" as RMBaseGraph

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "GpuGraph"

    // Config options
    property color temperatureColor: plasmoid.configuration.customGpuTemperatureColor ? plasmoid.configuration.gpuTemperatureColor : theme.textColor

    // Bind config changes
    Connections {
        target: plasmoid.configuration
        function onMemoryInPercentChanged() {
            uplimits = [100, plasmoid.configuration.gpuMemoryInPercent ? 100 : maxQueryModel.maxMemory];
            _clear();
        }
    }

    // Labels
    thresholds: [undefined, undefined, [plasmoid.configuration.thresholdWarningGpuTemp, plasmoid.configuration.thresholdCriticalGpuTemp]]

    textContainer {
        labelColors: [root.colors[0], root.colors[1], temperatureColor]
        valueColors: [undefined, undefined, temperatureColor]

        labels: ["GPU", (plasmoid.configuration.gpuMemoryGraph ? "VRAM" : ""), (plasmoid.configuration.showGpuTemperature ? i18n("🌡️ Temp.") : "")]
    }

    // Graph options
    // NOTE: "sensorsModel.sensors" set from "maxQueryModel"
    colors: [(plasmoid.configuration.customGpuColor ? plasmoid.configuration.gpuColor : theme.highlightColor), (plasmoid.configuration.customGpuMemoryColor ? plasmoid.configuration.gpuMemoryColor : theme.positiveTextColor)]

    // Override methods, for handle memeory in percent
    _update: () => {
        for (let i = 0; i < sensorsModel.sensors.length; i++) {
            let value = sensorsModel.getInfo(i);
            if (i === 1 && plasmoid.configuration.gpuMemoryInPercent) {
                value = (value / maxQueryModel.maxMemory) * 100;
            }
            root._insertChartData(i, value);

            // Update label
            if (textContainer.valueVisible) {
                _updateData(i);
            }
        }
    }
    _formatValue: (index, data) => {
        if (index === 1 && plasmoid.configuration.gpuMemoryInPercent) {
            return i18nc("Percent unit", "%1%", Math.round((data.value / maxQueryModel.maxMemory) * 1000) / 10); // This is for round to 1 decimal
        }
        return _defaultFormatValue(index, data);
    }

    // Initialize limits and threshold
    Sensors.SensorDataModel {
        id: maxQueryModel
        sensors: ["gpu/gpu0/totalVram"]
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

            // Update graph Y range and sensors
            root.uplimits = [100, plasmoid.configuration.gpuMemoryInPercent ? 100 : maxMemory];
            root.sensorsModel.sensors = ["gpu/gpu0/usage", "gpu/gpu0/usedVram", "gpu/gpu0/temperature"];
        }
    }
}
