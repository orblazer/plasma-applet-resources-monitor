import QtQuick 2.15
import org.kde.plasma.plasmoid 2.0
import "./base" as RMBaseGraph
import "../sensors" as RMSensors
import "../functions.js" as Functions

RMBaseGraph.SensorGraph {
    id: root
    objectName: "CpuGraph"

    // Config shrotcut
    property bool showClock: plasmoid.configuration.cpuClockAgregator !== "none"
    property string clockAgregator: (plasmoid.configuration.cpuClockAgregator !== "none" ? plasmoid.configuration.cpuClockAgregator : "maximum")
    property color temperatureColor: Functions.getColor("cpuTemperatureColor")

    // Handle config update
    Connections {
        target: plasmoid.configuration
        function onCpuUnitChanged() {
            _updateSensors();
        }
        function onCpuClockAgregatorChanged() {
            if (!manualFrequency.needManual) {
                _updateSensors();
            }
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

    // Manual cpu frequency handle
    // TODO (3.0): remove this
    _formatValue: (index, data) => {
        if (index === 1 && manualFrequency.needManual) {
            return manualFrequency.getFormattedValue();
        }
        return _defaultFormatValue(index, data);
    }

    RMSensors.CpuFrequency {
        id: manualFrequency
        agregator: clockAgregator

        onReady: _updateSensors()
    }

    function _updateSensors() {
        // Manual cpu frequency handle
    // TODO (3.0): remove this
        let frequencySensorId = "cpu/all/" + clockAgregator + "Frequency";
        if (manualFrequency.needManual) {
            frequencySensorId = "cpu/cpu0/frequency";
        }
        // END Manual cpu frequency handle
        sensorsModel.sensors = ["cpu/all/" + plasmoid.configuration.cpuUnit, frequencySensorId, "cpu/cpu0/temperature"];
    }
}
