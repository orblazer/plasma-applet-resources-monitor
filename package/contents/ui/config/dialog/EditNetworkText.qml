import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support
import "../controls" as RMControls
import "../../code/formatter.js" as Formatter
import "../../code/network.js" as NetworkUtils

/**
 * Settings format: {@link ../../code/graphs.js:79}
 */
BaseForm {
    id: root
    colorsType: ["text", "text", false]

    // List network interfaces
    property var interfaces: ListModel {}
    Plasma5Support.DataSource {
        engine: 'executable'
        connectedSources: [NetworkUtils.NET_DATA_SOURCE]

        onNewData: (sourceName, data) => {
            // run just once
            connectedSources.length = 0;
            if (data['exit code'] > 0) {
                print(data.stderr);
            } else {
                const transferData = NetworkUtils.parseTransferData(data.stdout);
                interfaces.clear();
                for (const name in transferData) {
                    interfaces.append({
                        name
                    });
                }
            }
        }
    }

    properties: Kirigami.FormLayout {
        QQC2.CheckBox {
            text: i18n("Swap first and second line")
            checked: root.item.sensorsType[0]
            onClicked: {
                root.item.sensorsType[0] = checked;
                root.changed();
            }
        }

        QQC2.CheckBox {
            text: i18n("Show icons (%1 / %2)", "↓", "↑")
            checked: root.item.icons
            onClicked: {
                root.item.icons = checked;
                root.changed();
            }
        }

        QQC2.ComboBox {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Unit:")

            textRole: "label"
            valueRole: "value"
            model: [
                {
                    "label": i18n("kibibyte (KiB/s)"),
                    "value": "kibibyte"
                },
                {
                    "label": i18n("kilobit (Kbps)"),
                    "value": "kilobit"
                },
                {
                    "label": i18n("kilobyte (KBps)"),
                    "value": "kilobyte"
                }
            ]

            Component.onCompleted: currentIndex = indexOfValue(root.item.sensorsType[1])
            onActivated: {
                root.item.sensorsType[1] = currentValue;
                root.changed();
            }
        }

        // Interfaces
        GridLayout {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Network interfaces:")

            columns: 2
            rowSpacing: Kirigami.Units.smallSpacing
            columnSpacing: Kirigami.Units.largeSpacing

            Repeater {
                model: root.interfaces
                delegate: QQC2.CheckBox {
                    text: name
                    checked: root.item.ignoredInterfaces.indexOf(name) == -1

                    onClicked: {
                        if (checked) {
                            // Checking, and thus removing from the ignoredNetworkInterfaces
                            var i = root.item.ignoredInterfaces.indexOf(name);
                            root.item.ignoredInterfaces.splice(i, 1);
                        } else {
                            // Unchecking, and thus adding to the ignoredNetworkInterfaces
                            root.item.ignoredInterfaces.push(name);
                        }
                        root.changed();
                    }
                }
            }
        }
    }
}
