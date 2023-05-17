import QtQuick 2.9
import org.kde.plasma.plasmoid 2.0
import "./base" as RMBaseGraph
import "../sensors" as RMSensors

RMBaseGraph.SensorGraph {
    id: root
    objectName: "CpuGraph"

    Connections {
        target: plasmoid.configuration
        function onCpuUnitChanged() {
            _updateSensors();
        }
        function onClockAgregatorChanged() {
            if (!manualFrequency.needManual) {
                _updateSensors();
            }
        }
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

        labels: ["CPU", (plasmoid.configuration.showClock ? i18nc("Graph label", "Clock") : ""), (plasmoid.configuration.showCpuTemperature ? i18nc("Graph label", "Temp.") : "")]
    }

    function _updateSensors() {
        // Manual cpu frequency handle
        // TODO (3.0): remove this
        let frequencySensorId = "cpu/all/" + plasmoid.configuration.clockAgregator + "Frequency";
        if (manualFrequency.needManual) {
            frequencySensorId = "cpu/cpu0/frequency";
        }
        // END Manual cpu frequency handle
        sensorsModel.sensors = ["cpu/all/" + plasmoid.configuration.cpuUnit, frequencySensorId, "cpu/cpu0/temperature"];
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
        agregator: plasmoid.configuration.clockAgregator

        onReady: _updateSensors()
    }
}
