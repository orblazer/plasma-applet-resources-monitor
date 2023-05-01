import QtQuick 2.9
import org.kde.plasma.plasmoid 2.0
import "./base" as RMBaseGraph

RMBaseGraph.SensorGraph {
    id: root
    objectName: "CpuGraph"

    Connections {
        target: Plasmoid.configuration
        function onCpuUnitChanged() {
            _updateSensors();
        }
    }
    Component.onCompleted: {
        _updateSensors();
    }

    // Config options
    property color temperatureColor: Plasmoid.configuration.customCpuTemperatureColor ? Plasmoid.configuration.cpuTemperatureColor : theme.textColor

    // Graph options
    // NOTE: "sensorsModel.sensors" is set by "_updateSensors"
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

        labels: ["CPU", (Plasmoid.configuration.showClock ? i18n("⏲ Clock") : ""), (Plasmoid.configuration.showCpuTemperature ? i18n("🌡️ Temp.") : "")]
    }

    function _updateSensors() {
        sensorsModel.sensors = ["cpu/all/" + Plasmoid.configuration.cpuUnit, "cpu/all/averageFrequency", "cpu/all/averageTemperature"];
    }
}
