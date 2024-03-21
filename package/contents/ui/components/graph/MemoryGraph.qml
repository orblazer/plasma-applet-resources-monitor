import QtQuick 2.15
import org.kde.plasma.plasmoid 2.0
import org.kde.ksysguard.sensors 1.0 as Sensors
import "./base" as RMBaseGraph
import "../functions.js" as Functions

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
            _updateSensorsAndLabels();
            if (oldLimit1 != uplimits[0]) {
                _clear();
            }
        }

        function onMemorySecondUnitChanged() {
            _updateSensorsAndLabels();
        }
        // TODO (3.0): Remove this legacy property
        function onMemorySwapGraphChanged() {
            _updateSensorsAndLabels();
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
        _updateSensorsAndLabels();
    }

    // Labels
    textContainer {
        labelColors: root.colors
        valueColors: [undefined, plasmoid.configuration.memorySwapGraph ? root.colors[1] : undefined]
        labelsVisibleWhenZero: [true, false, true]

        // NOTE: second label is set by "_updateSensorsAndLabels"
        labels: ["RAM", "...", ""]
    }

    // Graph options
    // NOTE: "sensorsModel.sensors" is set by "_updateSensorsAndLabels"
    colors: [Functions.getCustomConfig("ramColor", theme.highlightColor), (secondChartVisible ? Functions.getCustomConfig("swapColor", theme.negativeTextColor) : undefined)]
    secondChartVisible: plasmoid.configuration.memorySwapGraph

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
                root._updateSensorsAndLabels();
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
    function _updateSensorsAndLabels() {
        const info = plasmoid.configuration.memoryUnit.split("-");
        const oldSecondLabel = textContainer.labels[1];

        // Retrieve second line unit
        let secondUnit = plasmoid.configuration.memorySecondUnit;
        // TODO (3.0): Remove this legacy condition
        if (secondUnit == "") {
            if (plasmoid.configuration.memorySwapGraph) {
                secondUnit = "swap" + (info[1] === "percent" ? "-percent" : "");
            } else {
                secondUnit = "none";
            }
        }

        // Define sensors and second label
        const type = info[0] === "physical" ? "used" : "application";
        const suffix = info[1] === "percent" ? "Percent" : "";
        const memSensor = "memory/physical/" + type + suffix;
        let secondSensor;
        switch (secondUnit) {
        case "percent":
            secondSensor = "memory/physical/" + type + "Percent";
            textContainer.labels[1] = i18nc("Graph label", "Percent.");
            break;
        case "swap":
            secondSensor = "memory/swap/used";
            textContainer.labels[1] = "Swap";
            break;
        case "swap-percent":
            secondSensor = "memory/swap/usedPercent";
            textContainer.labels[1] = "Swap";
            break;
        case "none":
            sensorsModel.sensors = [memSensor];
            textContainer.labels[1] = "";

            // Force update labels
            if (oldSecondLabel != "") {
                textContainer.labels = textContainer.labels;
            }
            return;
        }
        sensorsModel.sensors = [memSensor, secondSensor];

        // Force update labels
        if (oldSecondLabel != textContainer.labels[1]) {
            textContainer.labels = textContainer.labels;
        }
    }
}
