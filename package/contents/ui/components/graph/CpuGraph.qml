import QtQuick
import org.kde.plasma.plasmoid
import "./base" as RMBaseGraph
import "../sensors" as RMSensors

RMBaseGraph.SensorGraph {
    id: root
    objectName: "CpuGraph"
    _update: () => {
        root._defaultUpdate()
        cpuTemperature.update()
    }

    // Settings
    property string clockAggregator: "average" // Values: average, minimum, maximum
    property int eCoresCount: 0

    // Config shortcut
    property bool showClock: sensorsType[1] !== "none"
    property bool clockIsECores: sensorsType[1] === "ecores"

    // Graph options
    sensorsModel.sensors: ["cpu/all/" + sensorsType[0], "cpu/cpu0/frequency", "cpu/all/maximumTemperature"]

    // Text options
    textContainer {
        valueColors: [undefined, root.colors[1], root.colors[2]]
        thresholdIndex: 2
        thresholds: root.thresholds // No change needed, simply map it

        hints: ["CPU", (root.showClock ? i18nc("Graph label", "Clock") : ""), (root.sensorsType[2] ? i18nc("Graph label", "Temp.") : "")]
    }

    // CPU frequency handle
    _formatValue: (index, value) => {
        if (index === 1) {
            return cpuFrequency.getFormattedValue(root.clockIsECores);
        }
        else if (index === 2) {
            return cpuTemperature.getFormattedValue();
        }
        return _defaultFormatValue(index, value);
    }

    RMSensors.CpuFrequency {
        id: cpuFrequency
        enabled: root.showClock
        aggregator: root.clockAggregator
        eCoresCount: root.eCoresCount
    }
    RMSensors.CpuTemperature {
        id: cpuTemperature
        enabled: root.sensorsType[2]
    }
}
