import QtQuick 2.9
import org.kde.plasma.plasmoid 2.0
import "./base" as RMBaseGraph
import "../" as RMComponents
import "../functions.js" as Functions

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "NetworkGraph"

    property var dialect: Functions.getNetworkDialectInfo(Plasmoid.configuration.networkUnit)

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
    Component.onCompleted: _updateUplimits();

    // Labels
    textContainer {
        labelColors: root.colors
        labels: [i18n("⇘ Down"), i18n("⇗ Up"), ""]
    }

    // Graph options
    colors: [(Plasmoid.configuration.customNetDownColor ? Plasmoid.configuration.netDownColor : theme.highlightColor), (Plasmoid.configuration.customNetUpColor ? Plasmoid.configuration.netUpColor : theme.positiveTextColor)]

    // Initialized sensors
    RMComponents.NetworkInterfaceDetector {
        id: networkInterfaces
        onModelChanged: _updateSensors()
    }

    // Override methods, for commulate sensors and support custom dialect
    _update: () => {
        // Cummulate sensors by group
        let data;
        let downloadValue = 0, uploadValue = 0;
        for (let i = 0; i < sensorsModel.sensors.length; i++) {
            data = sensorsModel.getData(i);
            if (data.sensorId.indexOf('/download') !== -1) {
                downloadValue += data.value;
            } else {
                uploadValue += data.value;
            }
        }

        // Fix dialect
        downloadValue *= dialect.KiBDiff;
        uploadValue *= dialect.KiBDiff;

        // Insert datas
        root._insertChartData(0, downloadValue);
        root._insertChartData(1, uploadValue);

        // Update label
        if (textContainer.valueVisible) {
            _updateData(0);
            _updateData(1);
        }
    }
    _formatValue: (_, data) => Functions.formatByteValue(data.value, dialect)

    function _updateSensors() {
        if (!visible || typeof networkInterfaces.model.count === "undefined") {
            return;
        }
        const sensors = [];
        for (let i = 0; i < networkInterfaces.model.count; i++) {
            const name = networkInterfaces.model.get(i).name;
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
