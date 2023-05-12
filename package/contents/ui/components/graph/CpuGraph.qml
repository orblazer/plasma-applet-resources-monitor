import QtQuick 2.9
import org.kde.plasma.plasmoid 2.0
import "./base" as RMBaseGraph

RMBaseGraph.SensorGraph {
    id: root
    objectName: "CpuGraph"

    Connections {
        target: plasmoid.configuration
        function onCpuUnitChanged() {
            _updateSensors();
        }
        function onClockAgregatorChanged() {
            _updateSensors();
        }
    }
    Component.onCompleted: {
        _updateSensors();
    }

    // Config options
    property color temperatureColor: plasmoid.configuration.customCpuTemperatureColor ? plasmoid.configuration.cpuTemperatureColor : theme.textColor

    // Graph options
    // NOTE: "sensorsModel.sensors" is set by "_updateSensors"
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

        labels: ["CPU", (plasmoid.configuration.showClock ? i18n("⏲ Clock") : ""), (plasmoid.configuration.showCpuTemperature ? i18n("🌡️ Temp.") : "")]
    }

    function _updateSensors() {
        sensorsModel.sensors = ["cpu/all/" + plasmoid.configuration.cpuUnit, "cpu/all/" + plasmoid.configuration.clockAgregator + "Frequency", "cpu/all/averageTemperature"];
    }
}
