import QtQuick
import org.kde.plasma.plasmoid
import "./base" as RMBaseGraph
import "../sensors" as RMSensors

RMBaseGraph.SensorGraph {
    id: root
    objectName: "CpuGraph"

    // Settings
    property string clockAgregator: "average" // Values: average, minimum, maximum
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
        return _defaultFormatValue(index, value);
    }

    RMSensors.CpuFrequency {
        id: cpuFrequenry
        enabled: root.showClock
        agregator: root.clockAgregator
        eCoresCount: root.eCoresCount
    }
}
