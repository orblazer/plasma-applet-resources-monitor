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
    // NOTE: "sensorsModel.sensors" is set by "_updateSensors"
    chart.yRange {
        from: 0
        to: 100
    }

    // Labels options
    thresholdIndex: 2
    realThresholds: thresholds // No change needed, simply map it
    textContainer {
        labelColors: [root.colors[0], undefined, root.colors[2]]
        valueColors: [undefined, undefined, root.colors[2]]

        labels: ["CPU", (root.showClock ? i18nc("Graph label", "Clock") : ""), (root.sensorsType[2] ? i18nc("Graph label", "Temp.") : "")]
    }

    // CPU frequency handle
    _formatValue: (index, data) => {
        if (index === 1) {
            return cpuFrequenry.getFormattedValue(root.clockIsEcores);
        }
        return _defaultFormatValue(index, data);
    }

    RMSensors.CpuFrequency {
        id: cpuFrequenry
        enabled: root.showClock
        agregator: root.clockAgregator
        eCoresCount: root.eCoresCount

        onReady: root._updateSensors()
    }

    function _updateSensors() {
        sensorsModel.sensors = ["cpu/all/" + sensorsType[0], "cpu/cpu0/frequency", "cpu/cpu0/temperature"];
    }
}
