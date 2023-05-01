import QtQuick 2.9
import org.kde.plasma.plasmoid 2.0
import "./base" as RMBaseGraph
import "../functions.js" as Functions

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "DisksGraph"

    readonly property var diskIoDialect: Functions.getNetworkDialectInfo("kibibyte")

    Connections {
        target: Plasmoid.configuration
        function onReadTotalChanged() {
            _updateUplimits();
        }
        function onWriteTotalChanged() {
            _updateUplimits();
        }
    }
    Component.onCompleted: {
        _updateUplimits();
    }

    // Labels
    textContainer {
        labelColors: root.colors
        labels: [i18n("⇗ Read"), i18n("⇘ Write"), ""]
    }

    // Graph options
    sensors: ["disk/all/read", "disk/all/write"]
    colors: [(Plasmoid.configuration.customDiskReadColor ? Plasmoid.configuration.diskReadColor : theme.highlightColor), (Plasmoid.configuration.customDiskWriteColor ? Plasmoid.configuration.diskWriteColor : theme.positiveTextColor)]

    function _updateUplimits() {
        uplimits = [Plasmoid.configuration.diskReadTotal * diskIoDialect.multiplier, Plasmoid.configuration.diskWriteTotal * diskIoDialect.multiplier];
    }
}
