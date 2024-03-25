import QtQuick
import org.kde.plasma.plasmoid
import "./base" as RMBaseGraph
import "../functions.mjs" as Functions

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "DisksGraph"

    // Apply dialect to uplimits
    readonly property var diskIoDialect: Functions.getNetworkDialectInfo("kibibyte", i18nc)
    Component.onCompleted: {
        realUplimits = [uplimits[0] * diskIoDialect.multiplier, uplimits[1] * diskIoDialect.multiplier];
    }

    // Labels
    textContainer {
        labels: [i18nc("Graph label", "Read"), i18nc("Graph label", "Write"), ""]
    }

    // Graph options
    sensorsModel.sensors: ["disk/all/read", "disk/all/write"]
}
