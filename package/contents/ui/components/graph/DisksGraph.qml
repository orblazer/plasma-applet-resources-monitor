import org.kde.plasma.plasmoid 2.0
import "./base" as RMBaseGraph
import "../functions.js" as Functions

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "DisksGraph"
    readonly property var diskIoDialect: Functions.getNetworkDialectInfo("kibibyte")

    // Config options
    property double readTotal: Plasmoid.configuration.diskReadTotal
    property double writeTotal: Plasmoid.configuration.diskWriteTotal

    property color readColor: Plasmoid.configuration.customDiskReadColor ? Plasmoid.configuration.diskReadColor : theme.highlightColor
    property color writeColor: Plasmoid.configuration.customDiskWriteColor ? Plasmoid.configuration.diskWriteColor : theme.positiveTextColor

    // Bind config changes
    onReadTotalChanged: {
        uplimits = [readTotal * diskIoDialect.multiplier, uplimits[1]];
    }
    onWriteTotalChanged: {
        uplimits = [uplimits[0], writeTotal * diskIoDialect.multiplier];
    }

    // Labels
    textContainer {
        labelColors: root.colors
        labels: [i18n("⇗ Read"), i18n("⇘ Write"), ""]
    }

    // Graph options
    sensors: ["disk/all/read", "disk/all/write"]
    colors: [readColor, writeColor]

    function _getUplimits() {
        return [readTotal * diskIoDialect.multiplier, writeTotal * diskIoDialect.multiplier];
    }
}
