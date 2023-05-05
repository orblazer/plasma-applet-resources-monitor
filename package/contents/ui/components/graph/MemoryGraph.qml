import QtQuick 2.9
import org.kde.plasma.plasmoid 2.0
import org.kde.ksysguard.sensors 1.0 as Sensors
import "./base" as RMBaseGraph

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "MemoryGraph"

    Connections {
        target: plasmoid.configuration
        function onMemoryUnitChanged() { // Values: usage, system, user
            const oldLimit1 = uplimits[0];
            if (plasmoid.configuration.memoryUnit.endsWith("-percent")) {
                uplimits = [100, 100];
            } else {
                uplimits = maxQueryModel.maxMemory;
            }
            _updateThresholds();
            _updateSensors();
            if (oldLimit1 != uplimits[0]) {
                _clear();
            }
        }

        function onShowSwapChanged() {
            _updateSensors();
        }

        function onThresholdWarningMemoryChanged() {
            _updateThresholds();
        }
        function onThresholdCriticalMemoryChanged() {
            _updateThresholds();
        }
    }
    Component.onCompleted: {
        _updateThresholds();
        _updateSensors();
    }

    // Labels
    textContainer {
        labelColors: root.colors
        valueColors: [undefined, root.colors[1]]
        labelsVisibleWhenZero: [true, false, true]

        labels: ["RAM", (plasmoid.configuration.memorySwapGraph ? "Swap" : ""), ""]
    }

    // Graph options
    // NOTE: "sensorsModel.sensors" is set by "_updateSensors"
    colors: [(plasmoid.configuration.customRamColor ? plasmoid.configuration.ramColor : theme.highlightColor), (plasmoid.configuration.customSwapColor ? plasmoid.configuration.swapColor : theme.negativeTextColor)]

    // Initialize limits and threshold
    Sensors.SensorDataModel {
        id: maxQueryModel
        sensors: ["memory/physical/total", "memory/swap/total"]
        enabled: true
        property var maxMemory: [-1, -1]

        onDataChanged: {
            // Update values
            const value = parseInt(data(topLeft, Sensors.SensorDataModel.Value));
            if (isNaN(value) || (topLeft.column === 0 && value <= 0)) {
                return;
            }
            maxMemory[topLeft.column] = value;

            // Update graph Y range and sensors
            if (maxMemory[0] > 0 && maxMemory[1] >= 0) {
                enabled = false;
                if (!plasmoid.configuration.memoryUnit.endsWith("-percent")) {
                    root.uplimits = maxMemory;
                }
                root._updateThresholds();
                root._updateSensors();
            }
        }
    }

    function _updateThresholds() {
        const thresholdWarningMemory = plasmoid.configuration.thresholdWarningMemory;
        const thresholdCriticalMemory = plasmoid.configuration.thresholdCriticalMemory;
        if (!plasmoid.configuration.memoryUnit.endsWith("-percent")) {
            thresholds[0] = [maxQueryModel.maxMemory[0] * (thresholdWarningMemory / 100.0), maxQueryModel.maxMemory[0] * (thresholdCriticalMemory / 100.0)];
        } else {
            thresholds[0] = [thresholdWarningMemory, thresholdCriticalMemory];
        }
    }
    function _updateSensors() {
        const info = plasmoid.configuration.memoryUnit.split("-");
        const suffix = info[1] === "percent" ? "Percent" : "";
        const memSensor = "memory/physical/" + (info[0] === "physical" ? "used" : "application") + suffix;
        if (plasmoid.configuration.memorySwapGraph) {
            sensorsModel.sensors = [memSensor, "memory/swap/used" + suffix];
        } else {
            sensorsModel.sensors = [memSensor];
        }
    }
}
