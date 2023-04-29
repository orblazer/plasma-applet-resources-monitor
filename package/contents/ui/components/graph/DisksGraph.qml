import "./base" as RMBaseGraph
import "../functions.js" as Functions

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "DisksGraph"
    readonly property var diskIoDialect: Functions.getNetworkDialectInfo("kibibyte")

    // Config options
    property double readTotal: plasmoid.configuration.diskReadTotal
    property double writeTotal: plasmoid.configuration.diskWriteTotal

    property color readColor: plasmoid.configuration.customDiskReadColor ? plasmoid.configuration.diskReadColor : theme.highlightColor
    property color writeColor: plasmoid.configuration.customDiskWriteColor ? plasmoid.configuration.diskWriteColor : theme.positiveTextColor

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
