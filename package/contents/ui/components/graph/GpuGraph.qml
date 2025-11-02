import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter
import "./base" as RMBaseGraph

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "GpuGraph"
    readonly property int minimumWidth: textContainer.enabled ? Formatter.Formatter.maximumLength(!memoryInPercent ? Formatter.Units.UnitMegaHertz : showTemp ? Formatter.Units.UnitCelsius : Formatter.Units.UnitPercent, textContainer.font) : 0

    // Settings
    property string device: "gpu0" // Device index (eg: gpu0, gpu1)

    // Config shortcut
    property bool memoryInPercent: sensorsType[0].endsWith("-percent")
    property bool showTemp: sensorsType[1] && device !== "all"

    // Labels
    textContainer {
        valueColors: [undefined, undefined, root.colors[2]]
        thresholdIndex: 2
        thresholds: root.thresholds // No change needed, simply map it

        hints: ["GPU", (secondChartVisible ? "VRAM" : ""), (showTemp ? i18nc("Graph label", "Temp.") : "")]
    }

    // Graph options
    sensorsModel.sensors: {
        let sensors = [`gpu/${device}/usage`, `gpu/${device}/usedVram`];
        if (showTemp) {
            sensors.push(`gpu/${device}/temperature`);
        }
        return sensors;
    }
    secondChartVisible: sensorsType[0] !== "none"

    // Override methods, for handle memory in percent
    _formatValue: (index, value) => {
        if (index === 1 && memoryInPercent) {
            return i18nc("Percent unit", "%1%", Math.round((value / root.realUplimits[1]) * 1000) / 10); // This is for round to 1 decimal
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
            root.realUplimits = [100, valueVar]
        }
    }
}
