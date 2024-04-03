import QtQuick
import org.kde.plasma.plasmoid
import "./base" as RMBaseGraph
import "../../code/formatter.js" as Formatter

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "DiskGraph"

    // Settings
    property string device: "all" // Device id (eg: sda, sdc) | Could be "all"
    readonly property var unit: Formatter.getUnitInfo("kibibyte", i18nc)

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
}
