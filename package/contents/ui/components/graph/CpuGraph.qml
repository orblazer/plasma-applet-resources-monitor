import "./base" as RMBaseGraph

RMBaseGraph.SensorGraph {
    id: root
    objectName: "CpuGraph"

    // Config options
    property string cpuUnit: plasmoid.configuration.cpuUnit
    property bool showClock: plasmoid.configuration.showClock
    property bool showTemperature: plasmoid.configuration.showCpuTemperature
    property color temperatureColor: plasmoid.configuration.customCpuTemperatureColor ? plasmoid.configuration.cpuTemperatureColor : theme.textColor

    // Bind config changes
    onCpuUnitChanged: {
        sensors = ["cpu/all/" + cpuUnit, "cpu/all/averageFrequency", "cpu/all/averageTemperature"];
    }

    // Graph options
    // NOTE: "sensors" is set by "_updateSensors"
    chartColor: plasmoid.configuration.customCpuColor ? plasmoid.configuration.cpuColor : theme.highlightColor

    chart.yRange {
        from: 0
        to: 100
    }

    // Labels options
    thresholds: [undefined, undefined, [plasmoid.configuration.thresholdWarningCpuTemp, plasmoid.configuration.thresholdCriticalCpuTemp]]

    textContainer {
        labelColors: [root.chartColor, undefined, temperatureColor]
        valueColors: [undefined, undefined, temperatureColor]

        labels: ["CPU", (showClock ? i18n("⏲ Clock") : ""), (showTemperature ? i18n("🌡️ Temp.") : "")]
    }
}
