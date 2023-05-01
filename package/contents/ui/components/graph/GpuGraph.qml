import org.kde.plasma.plasmoid 2.0
import org.kde.ksysguard.sensors 1.0 as Sensors
import "./base" as RMBaseGraph

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "GpuGraph"

    // Config options
    property bool showMemory: Plasmoid.configuration.gpuMemoryGraph
    property bool showTemperature: Plasmoid.configuration.showGpuTemperature
    property bool memoryInPercent: Plasmoid.configuration.gpuMemoryInPercent
    property color color: Plasmoid.configuration.customGpuColor ? Plasmoid.configuration.gpuColor : theme.highlightColor
    property color memoryColor: Plasmoid.configuration.customGpuMemoryColor ? Plasmoid.configuration.gpuMemoryColor : theme.positiveTextColor
    property color temperatureColor: Plasmoid.configuration.customGpuTemperatureColor ? Plasmoid.configuration.gpuTemperatureColor : theme.textColor

    // Bind config changes
    onMemoryInPercentChanged: {
        if (maxQueryModel.enabled) {
            return;
        }
        uplimits = [100, memoryInPercent ? 100 : maxQueryModel.maxMemory];
        _clear();
    }

    // Labels
    thresholds: [undefined, undefined, [Plasmoid.configuration.thresholdWarningGpuTemp, Plasmoid.configuration.thresholdCriticalGpuTemp]]

    textContainer {
        labelColors: [color, memoryColor, temperatureColor]
        valueColors: [undefined, undefined, temperatureColor]

        labels: ["GPU", (showMemory ? "VRAM" : ""), (showTemperature ? i18n("🌡️ Temp.") : "")]
    }

    // Graph options
    // NOTE: "sensors" set from "maxQueryModel"
    colors: [color, memoryColor]

    // Override methods, for handle memeory in percent
    _update: () => {
        for (let i = 0; i < sensors.length; i++) {
            let value = sensorsModel.getInfo(i)
            if(i === 1 && memoryInPercent) {
                value = value / uplimits[1]
            }
            root._insertChartData(i, value);

            // Update label
            if (textContainer.valueVisible) {
                _updateData(i);
            }
        }
    }
    _formatValue: (index, data) => {
        if (index === 1 && memoryInPercent) {
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
                root.uplimits = [100, memoryInPercent ? 100 : maxMemory];
                root.sensors = ["gpu/gpu0/usage", "gpu/gpu0/usedVram", "gpu/gpu0/temperature"]
            }
        }
    }
}
