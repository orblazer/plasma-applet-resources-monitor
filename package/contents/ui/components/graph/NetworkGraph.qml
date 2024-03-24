import QtQuick
import org.kde.plasma.plasmoid
import "./base" as RMBaseGraph
import "../" as RMComponents
import "../functions.js" as Functions

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "NetworkGraph"

    property var dialect: Functions.getNetworkDialectInfo(Plasmoid.configuration.networkUnit, i18nc)

    Connections {
        target: Plasmoid.configuration
        function onIgnoredNetworkInterfacesChanged() {
            _updateSensors();
        }

        function onNetworkReceivingTotalChanged() {
            _updateUplimits();
        }
        function onNetworkSendingTotalChanged() {
            _updateUplimits();
        }
    }
    Component.onCompleted: _updateUplimits()

    // Labels
    textContainer {
        labelColors: root.colors
        labels: [i18nc("Graph label", "Receiving"), i18nc("Graph label", "Sending"), ""]
    }

    // Graph options
    colors: [Functions.resolveColor(Plasmoid.configuration.netDownColor), Functions.resolveColor(Plasmoid.configuration.netUpColor)]

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
            if (Plasmoid.configuration.ignoredNetworkInterfaces.indexOf(name) === -1) {
                sensors.push("network/" + name + "/download", "network/" + name + "/upload");
            }
        }
        sensorsModel.sensors = sensors;
        _clear();
    }

    function _updateUplimits() {
        uplimits = [Plasmoid.configuration.networkReceivingTotal * dialect.multiplier, Plasmoid.configuration.networkSendingTotal * dialect.multiplier];
    }
}
