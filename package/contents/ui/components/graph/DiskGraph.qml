import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.formatter as Formatter
import "./base" as RMBaseGraph
import "../../code/formatter.js" as RMFormatter

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "DiskGraph"
    readonly property int minimumWidth: textContainer.enabled ? Formatter.Formatter.maximumLength(unit.id, textContainer.font) : 0

    // Settings
    property string device: "all" // Device ID (e.g.: "sda" or "sdc"); could be "all"
    property bool icons: false
    readonly property var unit: RMFormatter.getUnitInfo("kibibyte", i18nc)

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
    sensorsModel.sensors: sensorsType[0] ? [`disk/${device}/write`, `disk/${device}/read`] : [`disk/${device}/read`, `disk/${device}/write`]

    // Override methods to handle icons
    _formatValue: (index, value) => {
        // Show icons
        let icon = ""
        if (root.icons) {
            if (index === readIndex) {
                icon = "\u2009" + i18nc("Disk graph icon : Read", "R")
            } else if (index == writeIndex) {
                icon = "\u2009" + i18nc("Disk graph icon : Write", "W")
            }
        }

        return _defaultFormatValue(index, value) + icon;
    }
}
