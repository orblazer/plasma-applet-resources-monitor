import QtQuick 2.15
import org.kde.plasma.plasmoid 2.0
import "./base" as RMBaseGraph
import "../sensors" as RMSensors
import "../functions.js" as Functions

RMBaseGraph.SensorGraph {
    id: root
    objectName: "CpuGraph"

    // Config shrotcut
    property bool showClock: plasmoid.configuration.cpuClockType !== "none"
    property bool clockIsEcores: plasmoid.configuration.cpuClockType === "ecores"
    property color temperatureColor: Functions.getColor("cpuTemperatureColor")

    // Handle config update
    Connections {
        target: plasmoid.configuration
        function onCpuUnitChanged() {
            _updateSensors();
        }
    }

    // Graph options
    // NOTE: "sensorsModel.sensors" is set by "_updateSensors"
    chartColor: Functions.getColor("cpuColor")

    chart.yRange {
        from: 0
        to: 100
    }

    // Labels options
    thresholds: [undefined, undefined, [plasmoid.configuration.thresholdWarningCpuTemp, plasmoid.configuration.thresholdCriticalCpuTemp]]

    textContainer {
        labelColors: [root.chartColor, undefined, temperatureColor]
        valueColors: [undefined, undefined, temperatureColor]

        labels: ["CPU", (showClock ? i18nc("Graph label", "Clock") : ""), (plasmoid.configuration.showCpuTemperature ? i18nc("Graph label", "Temp.") : "")]
    }

    // CPU frequency handle
    _formatValue: (index, data) => {
        if (index === 1) {
            return cpuFrequenry.getFormattedValue(clockIsEcores);
        }
        return _defaultFormatValue(index, data);
    }

    RMSensors.CpuFrequency {
        id: cpuFrequenry
        enabled: showClock
        agregator: plasmoid.configuration.cpuClockAgregator

        onReady: _updateSensors()
    }

    function _updateSensors() {
        sensorsModel.sensors = ["cpu/all/" + plasmoid.configuration.cpuUnit, "cpu/cpu0/frequency", "cpu/cpu0/temperature"];
    }
}
