import QtQuick
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import "./base" as RMBaseGraph
import "../sensors" as RMSensors
import "../functions.mjs" as Functions

RMBaseGraph.SensorGraph {
    id: root
    objectName: "CpuGraph"

    // Config shrotcut
    property bool showClock: Plasmoid.configuration.cpuClockType !== "none"
    property bool clockIsEcores: Plasmoid.configuration.cpuClockType === "ecores"
    property color temperatureColor: Functions.resolveColor(Plasmoid.configuration.cpuTemperatureColor)

    // Handle config update
    Connections {
        target: Plasmoid.configuration
        function onCpuUnitChanged() {
            _updateSensors();
        }
    }

    // Graph options
    // NOTE: "sensorsModel.sensors" is set by "_updateSensors"
    chartColor: Functions.resolveColor(Plasmoid.configuration.cpuColor)

    chart.yRange {
        from: 0
        to: 100
    }

    // Labels options
    thresholds: [undefined, undefined, [Plasmoid.configuration.thresholdWarningCpuTemp, Plasmoid.configuration.thresholdCriticalCpuTemp]]

    textContainer {
        labelColors: [root.chartColor, undefined, temperatureColor]
        valueColors: [undefined, undefined, temperatureColor]

        labels: ["CPU", (showClock ? i18nc("Graph label", "Clock") : ""), (Plasmoid.configuration.showCpuTemperature ? i18nc("Graph label", "Temp.") : "")]
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
        agregator: Plasmoid.configuration.cpuClockAgregator
        eCoresCount: Plasmoid.configuration.cpuECoresCount

        onReady: _updateSensors()
    }

    function _updateSensors() {
        sensorsModel.sensors = ["cpu/all/" + Plasmoid.configuration.cpuUnit, "cpu/cpu0/frequency", "cpu/cpu0/temperature"];
    }
}
