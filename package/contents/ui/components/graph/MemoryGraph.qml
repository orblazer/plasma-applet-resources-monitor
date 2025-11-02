import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter
import "./base" as RMBaseGraph

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "MemoryGraph"
    readonly property int minimumWidth: textContainer.enabled ? Formatter.Formatter.maximumLength(fieldInPercent ? 1002 /* Formatter.Unit.UnitPercent */ : 302 /* Formatter.Unit.UnitMegaHertz */, textContainer.font) : 0

    // Config shortcut
    property bool showSwap: sensorsType[1].startsWith("swap")
    property var fieldInPercent: [sensorsType[0].endsWith("-percent"), sensorsType[1] === "swap-percent"]

    // Labels
    textContainer {
        valueColors: [undefined, root.showSwap ? root.colors[1] : undefined, undefined]
        labelsVisibleWhenZero: [true, false, true]
        thresholdIndex: 0
        thresholds: [maxQueryModel.maxMemory[0] * (thresholds[0] / 100.0), maxQueryModel.maxMemory[0] * (thresholds[1] / 100.0)]

        hints: ["RAM", root.showSwap ? "Swap" : (sensorsType[1] === "memory-percent" ? i18nc("Graph label", "Percent.") : ""), ""]
    }

    // Graph options
    realUplimits: maxQueryModel.maxMemory
    sensorsModel.sensors: {
        const info = sensorsType[0].split("-");
        const type = info[0] === "physical" ? "used" : "application";

        // Define sensors
        let sensors = ["memory/physical/" + type];
        if (showSwap) {
            sensors.push("memory/swap/used");
        } else if (sensorsType[1] === "memory-percent") {
            sensors.push("memory/physical/" + type + "Percent");
        }
        return sensors;
    }
    secondChartVisible: showSwap && Plasmoid.configuration.historyAmount > 0

    // Override methods, for handle memory in percent
    _formatValue: (index, value) => {
        if (fieldInPercent[index]) {
            return i18nc("Percent unit", "%1%", Math.round((value / maxQueryModel.maxMemory[index]) * 1000) / 10); // This is for round to 1 decimal
        }
        return _defaultFormatValue(index, value);
    }

    // Initialize limits and threshold
    Sensors.SensorDataModel {
        id: maxQueryModel
        sensors: ["memory/physical/total", "memory/swap/total"]
        enabled: true
        property var maxMemory: [-1, -1]

        onDataChanged: topLeft => {
            // Update values
            const value = parseInt(data(topLeft, Sensors.SensorDataModel.Value));
            if (isNaN(value) || (topLeft.column === 0 && value <= 0)) {
                return;
            }
            maxMemory[topLeft.column] = value;

            // Update graph Y range and sensors
            if (maxMemory[0] > 0 && maxMemory[1] >= 0) {
                enabled = false;
                maxMemory = maxMemory;
            }
        }
    }
}
