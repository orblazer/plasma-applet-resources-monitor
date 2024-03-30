import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../controls" as RMControls

Kirigami.FormLayout {
    id: root

    signal changed // Notify some settings as been changed

    /**
     * Settings format:
     * {
     *   "_v": 1, // Version of data (for compatibility)
     *   "type": "gpu",
     *   "colors": ["usageColor", "memoryColor", "tempColor"],
     *   "sensorsType": ["memory", temperature], // Values: "none/memory/memory-percent" | true/false
     *   "device": "gpu0", // Device index (eg. gpu0, gpu1) | [managed by graphs]
     *   "thresholds": [0, 0], // Temperature
     * }
     */
    required property var item

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
                "label": i18n("Memory (in KiB)"),
                "value": "memory"
            },
            {
                "label": i18n("Memory (in %)"),
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
        checked: item.sensorsType[1]
        onClicked: {
            item.sensorsType[1] = checked;
            root.changed();
        }
    }

    RMControls.Thresholds {
        Layout.fillWidth: true
        Kirigami.FormData.label: i18n("Temperature threshold:")

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

        value: item.colors[2]
        onValueChanged: {
            item.colors[2] = value;
            root.changed();
        }
    }
}
