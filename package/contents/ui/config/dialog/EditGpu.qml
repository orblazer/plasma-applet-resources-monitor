import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../controls" as RMControls

/**
 * Settings format: {@link ../../code/graphs.js:26}
 */
BaseForm {
    id: root
    readonly property bool showTempSettings: item.device !== "all"

    QQC2.ComboBox {
        Layout.fillWidth: true
        Kirigami.FormData.label: i18n("Second Line:")

        currentIndex: -1
        textRole: "label"
        valueRole: "value"
        model: [
            {
                "label": i18n("Disabled"),
                "value": "none"
            },
            {
                "label": i18n("Memory (B)"),
                "value": "memory"
            },
            {
                "label": i18n("Memory (%)"),
                "value": "memory-percent"
            }
        ]

        Component.onCompleted: currentIndex = indexOfValue(item.sensorsType[0])
        onActivated: {
            item.sensorsType[0] = currentValue;
            root.changed();
        }
    }

    QQC2.CheckBox {
        id: showGpuTemperature
        text: i18n("Show temperature")
        visible: showTempSettings

        checked: item.sensorsType[1]
        onClicked: {
            item.sensorsType[1] = checked;
            root.changed();
        }
    }

    RMControls.Thresholds {
        Layout.fillWidth: true
        Kirigami.FormData.label: i18n("Temperature threshold:")
        visible: showTempSettings

        values: item.thresholds
        onValuesChanged: {
            item.thresholds = values;
            root.changed();
        }

        decimals: 1
        stepSize: 1
        realFrom: 0.1
        realTo: 120
        suffix: " °C"
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
    RMControls.ColorSelector {
        Layout.fillWidth: true
        Kirigami.FormData.label: i18n("Third Line:")
        dialogTitle: i18nc("Chart color", "Choose text color")
        visible: showTempSettings

        value: item.colors[2]
        onValueChanged: {
            item.colors[2] = value;
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
