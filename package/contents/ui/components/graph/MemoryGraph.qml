import QtQuick 2.9
import org.kde.plasma.plasmoid 2.0
import org.kde.ksysguard.sensors 1.0 as Sensors
import "./base" as RMBaseGraph

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "MemoryGraph"

    Connections {
        target: Plasmoid.configuration
        function onMemoryUnitChanged() { // Values: usage, system, user
            const oldLimit1 = uplimits[0];
            if (Plasmoid.configuration.memoryUnit.endsWith("-percent")) {
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

        labels: ["RAM", (Plasmoid.configuration.memorySwapGraph ? "Swap" : ""), ""]
    }

    // Graph options
    // NOTE: "sensorsModel.sensors" is set by "_updateSensors"
    colors: [(Plasmoid.configuration.customRamColor ? Plasmoid.configuration.ramColor : theme.highlightColor), (Plasmoid.configuration.customSwapColor ? Plasmoid.configuration.swapColor : theme.negativeTextColor)]

    // Initialize limits and threshold
    Sensors.SensorDataModel {
        id: maxQueryModel
        sensors: ["memory/physical/total", "memory/swap/total"]
        enabled: true
        property var maxMemory: [-1, -1]

        onDataChanged: {
            // Update values
            const value = parseInt(data(topLeft, Sensors.SensorDataModel.Value));
            if (!isNaN(value) && maxMemory[topLeft.column] === -1) {
                maxMemory[topLeft.column] = value;
            }

            // Update graph Y range and sensors
            if (maxMemory[0] >= 0 && maxMemory[1] >= 0) {
                enabled = false;
                if (!Plasmoid.configuration.memoryUnit.endsWith("-percent")) {
                    root.uplimits = maxMemory;
                }
                root._updateThresholds();
                root._updateSensors();
            }
        }
    }

    function _updateThresholds() {
        const thresholdWarningMemory = Plasmoid.configuration.thresholdWarningMemory;
        const thresholdCriticalMemory = Plasmoid.configuration.thresholdCriticalMemory;
        if (!Plasmoid.configuration.memoryUnit.endsWith("-percent")) {
            thresholds[0] = [maxQueryModel.maxMemory[0] * (thresholdWarningMemory / 100.0), maxQueryModel.maxMemory[0] * (thresholdCriticalMemory / 100.0)];
        } else {
            thresholds[0] = [thresholdWarningMemory, thresholdCriticalMemory];
        }
    }
    function _updateSensors() {
        const info = Plasmoid.configuration.memoryUnit.split("-");
        const suffix = info[1] === "percent" ? "Percent" : "";
        const memSensor = "memory/physical/" + (info[0] === "physical" ? "used" : "application") + suffix;
        if (Plasmoid.configuration.memorySwapGraph) {
            sensorsModel.sensors = [memSensor, "memory/swap/used" + suffix];
        } else {
            sensorsModel.sensors = [memSensor];
        }
    }
}
