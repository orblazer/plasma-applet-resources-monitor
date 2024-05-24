import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support
import "../controls" as RMControls
import "../../code/formatter.js" as Formatter
import "../../code/network.js" as NetworkUtils

/**
 * Settings format: {@link ../../code/graphs.js:35}
 */
BaseForm {
    id: root

    readonly property var unit: Formatter.getUnitInfo(item.sensorsType[0], i18nc)
    readonly property var speedOptions: [
        {
            "label": i18n("Custom"),
            "value": -1
        },
        {
            "label": i18n("Automatic"),
            "value": 0.0
        },
        // Kilo options (pow 1)
        _getOption(100, 1),
        // Mega options (pow 2)
        _getOption(1, 2), _getOption(10, 2), _getOption(100, 2),
        // Giga options (pow 3)
        _getOption(1, 3), _getOption(2.5, 3), _getOption(5, 3), _getOption(10, 3)]

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

    // Transfer speed
    Item {
        Kirigami.FormData.label: i18n("Maximum transfer speed")
        Kirigami.FormData.isSection: true
    }
    RMControls.PredefinedSpinBox {
        id: receivingSpeed
        Layout.fillWidth: true
        Kirigami.FormData.label: i18nc("Chart config", "Receiving:")
        factor: 1000

        realValue: item.uplimits[0]
        onRealValueChanged: {
            item.uplimits[0] = receivingSpeed.realValue;
            root.changed();
        }

        predefinedChoices {
            textRole: "label"
            valueRole: "value"
            model: speedOptions
        }

        spinBox {
            decimals: 3
            stepSize: 1
            realFrom: 0.001
            suffix: " M" + unit.symbol
        }
    }
    RMControls.PredefinedSpinBox {
        id: sendingSpeed
        Layout.fillWidth: true
        Kirigami.FormData.label: i18nc("Chart config", "Sending:")
        factor: 1000

        realValue: item.uplimits[1]
        onRealValueChanged: {
            item.uplimits[1] = sendingSpeed.realValue;
            root.changed();
        }

        predefinedChoices {
            textRole: "label"
            valueRole: "value"
            model: speedOptions
        }

        spinBox {
            decimals: 3
            stepSize: 1
            realFrom: 0.001
            suffix: " M" + unit.symbol
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

    // Utils function
    function _getOption(value, pow = 0) {
        return {
            label: Formatter.formatValue(value * Math.pow(unit.multiplier, Math.max(0, pow)), unit, Qt.locale()),
            value: value * Math.pow(1000, Math.max(0, pow - 1))
        };
    }
}
