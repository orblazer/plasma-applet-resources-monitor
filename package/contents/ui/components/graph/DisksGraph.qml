import QtQuick
import org.kde.plasma.plasmoid
import "./base" as RMBaseGraph
import "../functions.mjs" as Functions

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "DisksGraph"

    readonly property var diskIoDialect: Functions.getNetworkDialectInfo("kibibyte", i18nc)

    Connections {
        target: Plasmoid.configuration
        function onDiskReadTotalChanged() {
            _updateUplimits();
        }
        function onDiskWriteTotalChanged() {
            _updateUplimits();
        }
    }
    Component.onCompleted: {
        _updateUplimits();
    }

    // Labels
    textContainer {
        labelColors: root.colors
        labels: [i18nc("Graph label", "Read"), i18nc("Graph label", "Write"), ""]
    }

    // Graph options
    sensorsModel.sensors: ["disk/all/read", "disk/all/write"]
    colors: [Functions.resolveColor(Plasmoid.configuration.diskReadColor), Functions.resolveColor(Plasmoid.configuration.diskWriteColor)]

    function _updateUplimits() {
        uplimits = [Plasmoid.configuration.diskReadTotal * diskIoDialect.multiplier, Plasmoid.configuration.diskWriteTotal * diskIoDialect.multiplier];
    }
}
