import QtQuick 2.9
import org.kde.plasma.plasmoid 2.0
import org.kde.ksysguard.sensors 1.0 as Sensors
import "./base" as RMBaseGraph

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "GpuGraph"

    // Config options
    property color temperatureColor: Plasmoid.configuration.customGpuTemperatureColor ? Plasmoid.configuration.gpuTemperatureColor : theme.textColor

    // Bind config changes
    Connections {
        target: Plasmoid.configuration
        function onMemoryInPercentChanged() {
            uplimits = [100, Plasmoid.configuration.gpuMemoryInPercent ? 100 : maxQueryModel.maxMemory];
            _clear();
        }
    }

    // Labels
    thresholds: [undefined, undefined, [Plasmoid.configuration.thresholdWarningGpuTemp, Plasmoid.configuration.thresholdCriticalGpuTemp]]

    textContainer {
        labelColors: [root.colors[0], root.colors[1], temperatureColor]
        valueColors: [undefined, undefined, temperatureColor]

        labels: ["GPU", (Plasmoid.configuration.gpuMemoryGraph ? "VRAM" : ""), (Plasmoid.configuration.showGpuTemperature ? i18n("🌡️ Temp.") : "")]
    }

    // Graph options
    // NOTE: "sensorsModel.sensors" set from "maxQueryModel"
    colors: [(Plasmoid.configuration.customGpuColor ? Plasmoid.configuration.gpuColor : theme.highlightColor), (Plasmoid.configuration.customGpuMemoryColor ? Plasmoid.configuration.gpuMemoryColor : theme.positiveTextColor)]

    // Override methods, for handle memeory in percent
    _update: () => {
        for (let i = 0; i < sensorsModel.sensors.length; i++) {
            let value = sensorsModel.getInfo(i);
            if (i === 1 && Plasmoid.configuration.gpuMemoryInPercent) {
                value = value / uplimits[1];
            }
            root._insertChartData(i, value);

            // Update label
            if (textContainer.valueVisible) {
                _updateData(i);
            }
        }
    }
    _formatValue: (index, data) => {
        if (index === 1 && Plasmoid.configuration.gpuMemoryInPercent) {
            return i18nc("Percent unit", "%1%", Math.round((data.value / uplimits[1]) * 100) / 100);
        }
        return _defaultFormatValue(index, data);
    }

    // Initialize limits and threshold
    Sensors.Sensor {
        id: maxQueryModel
        sensorId: "gpu/gpu0/totalVram"
        enabled: true
        property int maxMemory: -1

        onValueChanged: {
            // Update values
            const valueVar = parseInt(value);
            if (!isNaN(valueVar) && maxMemory === -1) {
                maxMemory = valueVar;
            }

            // Update graph Y range and sensors
            if (maxMemory >= 0) {
                enabled = false;
                root.uplimits = [100, Plasmoid.configuration.gpuMemoryInPercent ? 100 : maxMemory];
                root.sensorsModel.sensors = ["gpu/gpu0/usage", "gpu/gpu0/usedVram", "gpu/gpu0/temperature"];
            }
        }
    }
}
