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

    readonly property var unit: Formatter.getUnitInfo(item.sensorsType[0], i18nc)

    // List network interfaces
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
                interfaces.model.clear();
                for (const name in transferData) {
                    interfaces.model.append({
                        name
                    });
                }
            }
        }
    }

    QQC2.CheckBox {
        text: i18n("Swap first and second line")
        checked: item.sensorsType[0]
        onClicked: {
            item.sensorsType[0] = checked;
            root.changed();
        }
    }

    QQC2.CheckBox {
        text: i18n("Show icons (%1 / %2)", "↓", "↑")
        checked: item.icons
        onClicked: {
            item.icons = checked;
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

        Component.onCompleted: currentIndex = indexOfValue(item.sensorsType[1])
        onActivated: {
            item.sensorsType[1] = currentValue;
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
            id: interfaces
            model: ListModel {
            }
            delegate: QQC2.CheckBox {
                text: name
                checked: item.ignoredInterfaces.indexOf(name) == -1

                onClicked: {
                    if (checked) {
                        // Checking, and thus removing from the ignoredNetworkInterfaces
                        var i = item.ignoredInterfaces.indexOf(name);
                        item.ignoredInterfaces.splice(i, 1);
                    } else {
                        // Unchecking, and thus adding to the ignoredNetworkInterfaces
                        item.ignoredInterfaces.push(name);
                    }
                    root.changed();
                }
            }
        }
    }

    // Colors
    Kirigami.Separator {
        Kirigami.FormData.label: i18n("Colors")
        Kirigami.FormData.isSection: true
    }
    RMControls.ColorSelector {
        Layout.fillWidth: true
        Kirigami.FormData.label: i18n("First line:")
        dialogTitle: i18nc("Chart color", "Choose series color")

        value: item.colors[0]
        onValueChanged: {
            item.colors[0] = value;
            root.changed();
        }
    }
    RMControls.ColorSelector {
        Layout.fillWidth: true
        Kirigami.FormData.label: i18n("Second Line:")
        dialogTitle: i18nc("Chart color", "Choose text color")

        value: item.colors[1]
        onValueChanged: {
            item.colors[1] = value;
            root.changed();
        }
    }

    // Size
    Kirigami.Separator {
        Kirigami.FormData.label: i18n("Size")
        Kirigami.FormData.isSection: true
    }
    RMControls.CustomizableSize {
        id: graphWidth
        Kirigami.FormData.label: i18n("Width:")
        Layout.fillWidth: true
        property bool isReady: false

        Component.onCompleted: {
            if (item.sizes[0] != -1) {
                value = item.sizes[0]
                customized = true
            } else {
                customized = false
            }
        }
        onValueChanged: {
            if (!isReady) return
            console.log("value", value)
            item.sizes[0] = value;
            root.changed();
        }
        onCustomizedChanged: {
            if (!isReady) return
            item.sizes[0] = customized ? value : -1
            root.changed();
        }

        spinBox {
            from: 20
            to: 1000

            onReady: isReady = true
        }
    }
    RMControls.CustomizableSize {
        id: graphHeight
        Kirigami.FormData.label: i18n("Height:")
        Layout.fillWidth: true
        property bool isReady: false

        Component.onCompleted: {
            if (item.sizes[1] != -1) {
                value = item.sizes[1]
                customized = true
            } else {
                customized = false
            }
        }
        onValueChanged: {
            if (!isReady) return
            console.log("value", value)
            item.sizes[1] = value;
            root.changed();
        }
        onCustomizedChanged: {
            if (!isReady) return
            item.sizes[1] = customized ? value : -1
            root.changed();
        }

        spinBox {
            from: 20
            to: 1000

            onReady: isReady = true
        }
    }
}
