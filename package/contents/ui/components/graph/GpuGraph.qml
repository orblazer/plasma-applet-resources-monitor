import org.kde.ksysguard.sensors 1.0 as Sensors
import "./base" as RMBaseGraph

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "GpuGraph"

    // Config options
    property bool showMemory: plasmoid.configuration.gpuMemoryGraph
    property bool showTemperature: plasmoid.configuration.showGpuTemperature
    property bool memoryInPercent: plasmoid.configuration.gpuMemoryInPercent
    property color color: plasmoid.configuration.customGpuColor ? plasmoid.configuration.gpuColor : theme.highlightColor
    property color memoryColor: plasmoid.configuration.customGpuMemoryColor ? plasmoid.configuration.gpuMemoryColor : theme.positiveTextColor
    property color temperatureColor: plasmoid.configuration.customGpuTemperatureColor ? plasmoid.configuration.gpuTemperatureColor : theme.textColor

    // Bind config changes
    onMemoryInPercentChanged: {
        if (maxQueryModel.enabled) {
            return;
        }
        uplimits = [100, memoryInPercent ? 100 : maxQueryModel.maxMemory];
        _clear();
    }

    // Labels
    thresholds: [undefined, undefined, [plasmoid.configuration.thresholdWarningGpuTemp, plasmoid.configuration.thresholdCriticalGpuTemp]]

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
