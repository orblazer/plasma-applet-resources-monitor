import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.sensors as Sensors
import "./base" as RMBaseGraph
import "../functions.mjs" as Functions

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "MemoryGraph"

    // Config shrotcut
    property bool showSwap: Plasmoid.configuration.memorySecondUnit.startsWith("swap")
    property var fieldInPercent: [Plasmoid.configuration.memoryUnit.endsWith("-percent"), Plasmoid.configuration.memorySecondUnit === "swap-percent"]

    // Handle config update and init
    Connections {
        target: Plasmoid.configuration
        function onMemoryUnitChanged() { // Values: usage, system, user
            _updateSensorsAndLabels();
        }
        function onMemorySecondUnitChanged() {
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
        valueColors: [undefined, showSwap ? root.colors[1] : undefined]
        labelsVisibleWhenZero: [true, false, true]

        // NOTE: second label is set by "_updateSensorsAndLabels"
        labels: ["RAM", "...", ""]
    }

    // Graph options
    // NOTE: "sensorsModel.sensors" is set by "_updateSensorsAndLabels"
    colors: [Functions.resolveColor(Plasmoid.configuration.memColor), Functions.resolveColor(Plasmoid.configuration.memSecondColor)]
    secondChartVisible: showSwap && Plasmoid.configuration.historyAmount > 0

    // Override methods, for handle memeory in percent
    _formatValue: (index, data) => {
        if (fieldInPercent[index]) {
            return i18nc("Percent unit", "%1%", Math.round((data.value / maxQueryModel.maxMemory[index]) * 1000) / 10); // This is for round to 1 decimal
        }
        return _defaultFormatValue(index, data);
    }

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
                root.uplimits = maxMemory;
                root._updateThresholds();
                root._updateSensorsAndLabels();
            }
        }
    }

    function _updateThresholds() {
        const thresholdWarningMemory = Plasmoid.configuration.thresholdWarningMemory;
        const thresholdCriticalMemory = Plasmoid.configuration.thresholdCriticalMemory;
        thresholds[0] = [maxQueryModel.maxMemory[0] * (thresholdWarningMemory / 100.0), maxQueryModel.maxMemory[0] * (thresholdCriticalMemory / 100.0)];
    }
    function _updateSensorsAndLabels() {
        const info = Plasmoid.configuration.memoryUnit.split("-");
        const oldSecondLabel = textContainer.labels[1];

        // Define sensors and second label
        const type = info[0] === "physical" ? "used" : "application";
        const firstSensor = "memory/physical/" + type;
        let secondSensor;
        switch (Plasmoid.configuration.memorySecondUnit) {
        case "memory-percent":
            secondSensor = "memory/physical/" + type + "Percent";
            textContainer.labels[1] = i18nc("Graph label", "Percent.");
            break;
        case "swap":
        case "swap-percent":
            secondSensor = "memory/swap/used";
            textContainer.labels[1] = "Swap";
            break;
        case "none":
            sensorsModel.sensors = [firstSensor];
            textContainer.labels[1] = "";

            // Force update labels
            if (oldSecondLabel != "") {
                textContainer.labels = textContainer.labels;
            }
            return;
        }
        sensorsModel.sensors = [firstSensor, secondSensor];

        // Force update labels
        if (oldSecondLabel != textContainer.labels[1]) {
            textContainer.labels = textContainer.labels;
        }
    }
}
