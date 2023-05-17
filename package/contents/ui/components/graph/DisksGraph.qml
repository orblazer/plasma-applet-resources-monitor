import QtQuick 2.9
import org.kde.plasma.plasmoid 2.0
import "./base" as RMBaseGraph
import "../functions.js" as Functions

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "DisksGraph"

    readonly property var diskIoDialect: Functions.getNetworkDialectInfo("kibibyte")

    Connections {
        target: plasmoid.configuration
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
    colors: [(plasmoid.configuration.customDiskReadColor ? plasmoid.configuration.diskReadColor : theme.highlightColor), (plasmoid.configuration.customDiskWriteColor ? plasmoid.configuration.diskWriteColor : theme.positiveTextColor)]

    function _updateUplimits() {
        uplimits = [plasmoid.configuration.diskReadTotal * diskIoDialect.multiplier, plasmoid.configuration.diskWriteTotal * diskIoDialect.multiplier];
    }
}
