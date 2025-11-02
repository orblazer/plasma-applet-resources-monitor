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
    colorsType: ["series", "text", "text"]

    readonly property bool showTempSettings: item.device !== "all"

    properties: Kirigami.FormLayout {
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

            Component.onCompleted: currentIndex = indexOfValue(root.item.sensorsType[0])
            onActivated: {
                root.item.sensorsType[0] = currentValue;
                root.changed();
            }
        }

        QQC2.CheckBox {
            id: showGpuTemperature
            text: i18n("Show temperature")
            visible: showTempSettings

            checked: root.item.sensorsType[1]
            onClicked: {
                root.item.sensorsType[1] = checked;
                root.changed();
            }
        }

        RMControls.Thresholds {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Temperature threshold:")
            visible: showTempSettings

            values: root.item.thresholds
            onValuesChanged: {
                root.item.thresholds = values;
                root.changed();
            }

            decimals: 1
            stepSize: 1
            realFrom: 0.1
            realTo: 120
            suffix: " °C"
        }
    }
}
