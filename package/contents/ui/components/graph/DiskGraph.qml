import QtQuick
import org.kde.plasma.plasmoid
import "./base" as RMBaseGraph
import "../../code/formatter.js" as Formatter

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "DiskGraph"

    // Settings
    property string device: "all" // Device id (eg: sda, sdc) | Could be "all"
    property bool icons: false
    readonly property var unit: Formatter.getUnitInfo("kibibyte", i18nc)

    // Retrieve chart index and swap it if needed
    readonly property int readIndex: sensorsType[0] ? 1 : 0
    readonly property int writeIndex: sensorsType[0] ? 0 : 1

    // Labels
    textContainer {
        hints: {
            const read = i18nc("Graph label", "Read");
            const write = i18nc("Graph label", "Write");
            return sensorsType[0] ? [write, read, ""] : [read, write, ""];
        }
    }

    // Graph options
    realUplimits: [uplimits[0] * unit.multiplier, uplimits[1] * unit.multiplier]
    sensorsModel.sensors: sensorsType[0] ? [`disk/${device}/read`, `disk/${device}/write`] : [`disk/${device}/write`, `disk/${device}/read`]

    // Override methods, for handle icons
    _formatValue: (index, value) => {
        // Show icons
        let icon = ""
        if (root.icons) {
            if (index === readIndex) {
                icon = " " + i18nc("Disk graph icon : Read", " R")
            } else if (index == writeIndex) {
                icon = " " + i18nc("Disk graph icon : Write", "W")
            }
        }

        return _defaultFormatValue(index, value) + icon;
    }
}
