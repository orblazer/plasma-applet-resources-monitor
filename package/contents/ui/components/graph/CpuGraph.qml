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
    property bool clockIsEcores: sensorsType[1] === "ecores"

    // Graph options
    sensorsModel.sensors: ["cpu/all/" + sensorsType[0], "cpu/cpu0/frequency", "cpu/all/maximumTemperature"]

    // Text options
    thresholdIndex: 2
    realThresholds: thresholds // No change needed, simply map it
    textContainer {
        valueColors: [undefined, undefined, root.colors[2]]

        hints: ["CPU", (root.showClock ? i18nc("Graph label", "Clock") : ""), (root.sensorsType[2] ? i18nc("Graph label", "Temp.") : "")]
    }

    // CPU frequency handle
    _formatValue: (index, value) => {
        if (index === 1) {
            return cpuFrequenry.getFormattedValue(root.clockIsEcores);
        }
        else if (index === 2) {
            return cpuTemperature.getFormattedValue();
        }
        return _defaultFormatValue(index, value);
    }

    RMSensors.CpuFrequency {
        id: cpuFrequenry
        enabled: root.showClock
        aggregator: root.clockAggregator
        eCoresCount: root.eCoresCount
    }
    RMSensors.CpuTemperature {
        id: cpuTemperature
        enabled: root.sensorsType[2]
    }
}
