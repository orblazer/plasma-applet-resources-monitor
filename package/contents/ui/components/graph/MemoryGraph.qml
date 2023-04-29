import org.kde.ksysguard.sensors 1.0 as Sensors
import "./base" as RMBaseGraph

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "MemoryGraph"

    // Config options
    property string memoryUnit: plasmoid.configuration.memoryUnit // Values: usage, system, user
    property bool showSwap: plasmoid.configuration.memorySwapGraph
    property color color: plasmoid.configuration.customRamColor ? plasmoid.configuration.ramColor : theme.highlightColor
    property color swapColor: plasmoid.configuration.customSwapColor ? plasmoid.configuration.swapColor : theme.negativeTextColor

    property double thresholdWarningMemory: plasmoid.configuration.thresholdWarningMemory
    property double thresholdCriticalMemory: plasmoid.configuration.thresholdCriticalMemory

    // Bind config changes
    onMemoryUnitChanged: {
        if (maxQueryModel.enabled) {
            return;
        }
        const oldLimit1 = uplimits[0];
        if (memoryUnit.endsWith("-percent")) {
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
    onShowSwapChanged: _updateSensors()

    onThresholdWarningMemoryChanged: _updateThresholds()
    onThresholdCriticalMemoryChanged: _updateThresholds()

    // Labels
    textContainer {
        labelColors: [color, swapColor]
        valueColors: [undefined, swapColor]
        labelsVisibleWhenZero: [true, false, true]

        labels: ["RAM", (showSwap ? "Swap" : ""), ""]
    }

    // Graph options
    // NOTE: "sensors" is set by "_updateSensors"
    colors: [color, swapColor]

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
                if (!memoryUnit.endsWith("-percent")) {
                    root.uplimits = maxMemory;
                }
                root._updateThresholds();
                root._updateSensors();
            }
        }
    }

    function _updateThresholds() {
        if (!memoryUnit.endsWith("-percent")) {
            thresholds[0] = [maxQueryModel.maxMemory[0] * (thresholdWarningMemory / 100.0), maxQueryModel.maxMemory[0] * (thresholdCriticalMemory / 100.0)];
        } else {
            thresholds[0] = [thresholdWarningMemory, thresholdCriticalMemory];
        }
    }
    function _updateSensors() {
        const info = memoryUnit.split("-");
        const suffix = info[1] === "percent" ? "Percent" : "";
        const memSensor = "memory/physical/" + (info[0] === "physical" ? "used" : "application") + suffix;
        if (showSwap) {
            sensors = [memSensor, "memory/swap/used" + suffix];
        } else {
            sensors = [memSensor];
        }
    }
}
