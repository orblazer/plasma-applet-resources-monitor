import QtQuick
import org.kde.plasma.plasmoid
import "./base" as RMBaseGraph
import "../../code/dialect.js" as Dialect

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "DisksGraph"

    // Apply dialect to uplimits
    readonly property var diskIoDialect: Dialect.getNetworkDialectInfo("kibibyte", i18nc)

    // Labels
    textContainer {
        hints: {
            const read = i18nc("Graph label", "Read");
            const write = i18nc("Graph label", "Write");
            return sensorsType[0] ? [write, read, ""] : [read, write, ""];
        }
    }

    // Graph options
    realUplimits: [uplimits[0] * diskIoDialect.multiplier, uplimits[1] * diskIoDialect.multiplier]
    sensorsModel.sensors: sensorsType[0] ? ["disk/all/read", "disk/all/write"] : ["disk/all/write", "disk/all/read"]
}
