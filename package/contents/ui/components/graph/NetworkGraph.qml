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

    // Apply dialect to uplimits
    Component.onCompleted: {
        realUplimits = [uplimits[0] * dialect.multiplier, uplimits[1] * dialect.multiplier];
    }

    // Labels
    textContainer {
        labels: [i18nc("Graph label", "Receiving"), i18nc("Graph label", "Sending"), ""]
    }

    // Initialized sensors
    RMComponents.NetworkInterfaceDetector {
        id: networkInterfaces
        onReady: _updateSensors()
    }

    // Override methods, for commulate sensors and support custom dialect
    property var _downloadValue
    property var _uploadValue

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

        // Fix dialect AND store it for update label
        _downloadValue = downloadValue *= dialect.KiBDiff;
        _uploadValue = uploadValue *= dialect.KiBDiff;

        // Insert datas
        root._insertChartData(0, downloadValue);
        root._insertChartData(1, uploadValue);

        // Update label
        if (textContainer.enabled && textContainer.valueVisible) {
            _updateData(0);
            _updateData(1);
        }
    }

    function _updateData(index) {
        // Cancel update if first data is not here
        if (!sensorsModel.hasIndex(0, 0)) {
            return;
        }

        // Retrieve label need to update
        const label = _getLabel(index);
        if (typeof label === "undefined" || !label.enabled) {
            return;
        }
        const value = index === 0 ? _downloadValue : _uploadValue;

        // Show value on label
        label.text = Functions.formatByteValue(value, dialect);
        label.visible = true;
    }

    function _updateSensors() {
        if (typeof networkInterfaces.count === "undefined") {
            return;
        }
        const sensors = [];
        for (let i = 0; i < networkInterfaces.count; i++) {
            const name = networkInterfaces.getInterfaceName(i);
            if (typeof name === 'undefined') {
                continue;
            }
            if (root.ignoredInterfaces.indexOf(name) === -1) {
                sensors.push("network/" + name + "/download", "network/" + name + "/upload");
            }
        }
        sensorsModel.sensors = sensors;
    }
}
