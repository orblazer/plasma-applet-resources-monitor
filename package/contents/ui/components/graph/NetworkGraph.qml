import org.kde.plasma.plasmoid 2.0
import "./base" as RMBaseGraph
import "../" as RMComponents
import "../functions.js" as Functions

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "NetworkGraph"

    // Config options
    property var ignoredNetworkInterfaces: Plasmoid.configuration.ignoredNetworkInterfaces
    property var dialect: Functions.getNetworkDialectInfo(Plasmoid.configuration.networkUnit)
    property double networkReceivingTotal: Plasmoid.configuration.networkReceivingTotal
    property double networkSendingTotal: Plasmoid.configuration.networkSendingTotal

    property color downloadColor: Plasmoid.configuration.customNetDownColor ? Plasmoid.configuration.netDownColor : theme.highlightColor
    property color uploadColor: Plasmoid.configuration.customNetUpColor ? Plasmoid.configuration.netUpColor : theme.positiveTextColor

    // Bind config changes
    onIgnoredNetworkInterfacesChanged: _updateSensors()

    onNetworkReceivingTotalChanged: {
        uplimits = [networkReceivingTotal * dialect.multiplier, uplimits[1]];
    }
    onNetworkSendingTotalChanged: {
        uplimits = [uplimits[0], networkSendingTotal * dialect.multiplier];
    }

    // Labels
    textContainer {
        labelColors: root.colors
        labels: [i18n("⇘ Down"), i18n("⇗ Up"), ""]
    }

    // Graph options
    colors: [downloadColor, uploadColor]

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
        for (let i = 0; i < sensors.length; i++) {
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
        let _sensors = [];
        for (let i = 0; i < networkInterfaces.model.count; i++) {
            const name = networkInterfaces.model.get(i).name;
            if (ignoredNetworkInterfaces.indexOf(name) === -1) {
                _sensors.push("network/" + name + "/download", "network/" + name + "/upload");
            }
        }
        sensors = _sensors;
        _clear();
    }
}
