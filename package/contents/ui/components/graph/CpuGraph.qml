import org.kde.plasma.plasmoid 2.0
import "./base" as RMBaseGraph

RMBaseGraph.SensorGraph {
    id: root
    objectName: "CpuGraph"

    // Config options
    property string cpuUnit: Plasmoid.configuration.cpuUnit
    property bool showClock: Plasmoid.configuration.showClock
    property bool showTemperature: Plasmoid.configuration.showCpuTemperature
    property color temperatureColor: Plasmoid.configuration.customCpuTemperatureColor ? Plasmoid.configuration.cpuTemperatureColor : theme.textColor

    // Bind config changes
    onCpuUnitChanged: {
        sensors = ["cpu/all/" + cpuUnit, "cpu/all/averageFrequency", "cpu/all/averageTemperature"];
    }

    // Graph options
    // NOTE: "sensors" is set by "_updateSensors"
    chartColor: Plasmoid.configuration.customCpuColor ? Plasmoid.configuration.cpuColor : theme.highlightColor

    chart.yRange {
        from: 0
        to: 100
    }

    // Labels options
    thresholds: [undefined, undefined, [Plasmoid.configuration.thresholdWarningCpuTemp, Plasmoid.configuration.thresholdCriticalCpuTemp]]

    textContainer {
        labelColors: [root.chartColor, undefined, temperatureColor]
        valueColors: [undefined, undefined, temperatureColor]

        labels: ["CPU", (showClock ? i18n("⏲ Clock") : ""), (showTemperature ? i18n("🌡️ Temp.") : "")]
    }
}
