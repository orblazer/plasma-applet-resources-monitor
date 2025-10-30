import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.formatter as KFormatter
import "./base" as RMBase
import "../sensors" as RMSensors
import "../../code/formatter.js" as Formatter

RMBase.BaseSensorText {
    id: root
    objectName: "NetworkText"
    sensor.enabled: false // Disable base sensor due to use custom one
    _update: networkSpeed.execute

    // Settings
    property var ignoredInterfaces: []
    property bool icons: false
    readonly property var unit: Formatter.getUnitInfo(sensorsType[1], i18nc)

    // Retrieve chart index and swap it if needed
    readonly property int downloadIndex: sensorsType[0] ? 1 : 0
    readonly property int uploadIndex: sensorsType[0] ? 0 : 1

    // Text options
    textContainer {
        hints: {
            const receiving = i18nc("Graph label", "Receiving");
            const sending = i18nc("Graph label", "Sending");
            return sensorsType[0] ? [sending, receiving, ""] : [receiving, sending, ""];
        }
    }

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
                if (root.ignoredInterfaces.indexOf(ifname) !== -1) {
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

            // Apply selected unit
            downloadValue *= unit.byteDiff;
            uploadValue *= unit.byteDiff;

            // Update labels
            if (textContainer.enabled && textContainer.valueVisible) {
                _updateData(downloadIndex, downloadValue);
                _updateData(uploadIndex, uploadValue);
            }
        }
    }

    function _updateData(index, value) {
        let icon = ""
        if (root.icons) {
            if (index == downloadIndex) {
                icon = "↓ "
            } else if (index == uploadIndex) {
                icon = "↑ "
            }
        }

        textContainer.setValue(index, value, icon + Formatter.formatValue(value, unit, Qt.locale()))
    }
}
