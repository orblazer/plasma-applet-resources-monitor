import QtQuick
import org.kde.plasma.plasmoid
import "./base" as RMBaseGraph
import "../" as RMComponents
import "../../code/dialect.js" as Dialect

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "NetworkGraph"

    // Settings
    property var ignoredInterfaces: []
    property var dialect: Dialect.getNetworkDialectInfo(sensorsType[1], i18nc)

    // Retrieve chart index and swap it if needed
    property int downloadIndex: sensorsType[0] ? 1 : 0
    property int uploadIndex: sensorsType[0] ? 0 : 1

    // Labels
    textContainer {
        hints: {
            const receiving = i18nc("Graph label", "Receiving");
            const sending = i18nc("Graph label", "Sending");
            return sensorsType[0] ? [sending, receiving, ""] : [receiving, sending, ""];
        }
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
        _insertChartData(downloadIndex, downloadValue);
        _insertChartData(uploadIndex, uploadValue);

        // Update labels
        if (textContainer.enabled && textContainer.valueVisible) {
            _updateData(downloadIndex, downloadValue);
            _updateData(uploadIndex, uploadValue);
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
