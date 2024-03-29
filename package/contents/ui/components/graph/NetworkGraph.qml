import QtQuick
import org.kde.plasma.plasmoid
import "./base" as RMBaseGraph
import "../" as RMComponents
import "../functions.mjs" as Functions

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "NetworkGraph"

    // Settings
    property var ignoredInterfaces: []
    property var dialect: Functions.getNetworkDialectInfo(sensorsType[0], i18nc)

    // Labels
    textContainer {
        hints: [i18nc("Graph label", "Receiving"), i18nc("Graph label", "Sending"), ""]
    }

    // Initialized sensors
    RMComponents.NetworkInterfaceDetector {
        onReady: {
            if (typeof count === "undefined") {
                return;
            }
            const sensors = [];
            for (let i = 0; i < count; i++) {
                const name = getInterfaceName(i);
                if (typeof name === 'undefined') {
                    continue;
                }
                if (root.ignoredInterfaces.indexOf(name) === -1) {
                    sensors.push("network/" + name + "/download", "network/" + name + "/upload");
                }
            }
            root.sensorsModel.sensors = sensors;
        }
    }

    realUplimits: [uplimits[0] * dialect.multiplier, uplimits[1] * dialect.multiplier]

    // Override methods, for cummulate sensors and support custom dialect
    _update: () => {
        // Cummulate sensors by group
        let data;
        let downloadValue = 0, uploadValue = 0;
        for (let i = 0; i < sensorsModel.sensors.length; i++) {
            data = sensorsModel.getValue(i);
            if (typeof data === "undefined") {
                continue;
            } else if (data.sensorId.indexOf('/download') !== -1) {
                downloadValue += data.value;
            } else {
                uploadValue += data.value;
            }
        }

        // Apply selected dialect
        downloadValue *= dialect.KiBDiff;
        uploadValue *= dialect.KiBDiff;

        // Insert datas
        _insertChartData(0, downloadValue);
        _insertChartData(1, uploadValue);

        // Update labels
        if (textContainer.enabled && textContainer.valueVisible) {
            _updateData(0, downloadValue);
            _updateData(1, uploadValue);
        }
    }

    function _updateData(index, value) {
        // Cancel update if first data is not here
        if (!sensorsModel.hasIndex(0, 0)) {
            return;
        }

        // Retrieve label need to update
        const label = textContainer.getLabel(index);
        if (typeof label === "undefined" || !label.enabled) {
            return;
        }

        // Show value on label
        label.text = Functions.formatByteValue(value, dialect);
        label.visible = true;
    }
}
