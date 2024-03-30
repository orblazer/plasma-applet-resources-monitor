import QtQuick 2.9
import org.kde.plasma.plasmoid 2.0
import "./base" as RMBaseGraph
import "../sensors" as RMSensors
import "../functions.js" as Functions

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "NetworkGraph"
    sensorsModel.enabled: false // Disable base sensort due to use custom one
    _update: networkSpeed.execute

    property var dialect: Functions.getNetworkDialectInfo(plasmoid.configuration.networkUnit)

    Connections {
        target: plasmoid.configuration
        function onIgnoredNetworkInterfacesChanged() {
            _clear();
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
    colors: [(plasmoid.configuration.customNetDownColor ? plasmoid.configuration.netDownColor : theme.highlightColor), (plasmoid.configuration.customNetUpColor ? plasmoid.configuration.netUpColor : theme.positiveTextColor)]

    // Custom sensor
    RMSensors.NetworkSpeed {
        id: networkSpeed

        function cummulateSpeeds() {
            const data = Object.entries(value ?? {});
            if (data.length === 0) {
                return [undefined, undefined];
            }
            // Cumulate speeds
            let download = 0, upload = 0;
            for (const [ifname, speed] of data) {
                if (plasmoid.configuration.ignoredNetworkInterfaces.indexOf(ifname) !== -1) {
                    continue;
                }
                download += speed[0];
                upload += speed[1];
            }
            return [download, upload];
        }

        onValueChanged: {
            let [downloadValue, uploadValue] = cummulateSpeeds();
            if (typeof downloadValue === "undefined") {
                // Skip first run
                return;
            }

            // Apply selected dialect
            downloadValue *= dialect.byteDiff;
            uploadValue *= dialect.byteDiff;

            // Insert datas
            _insertChartData(0, downloadValue);
            _insertChartData(1, uploadValue);

            // Update labels
            if (textContainer.enabled && textContainer.valueVisible) {
                _updateData(0, downloadValue);
                _updateData(1, uploadValue);
            }
        }
    }

    function _updateData(index, value) {
        // Retrieve label need to update
        const label = _getLabel(index);
        if (typeof label === "undefined" || !label.enabled) {
            return;
        }

        // Show value on label
        label.text = Functions.formatByteValue(value, dialect);
        label.visible = true;
    }

    function _updateUplimits() {
        uplimits = [plasmoid.configuration.networkReceivingTotal * dialect.multiplier, plasmoid.configuration.networkSendingTotal * dialect.multiplier];
    }
}
