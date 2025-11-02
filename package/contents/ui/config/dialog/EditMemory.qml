import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../controls" as RMControls

/**
 * Settings format: {@link ../../code/graphs.js:18}
 */
BaseForm {
    id: root
    colorsType: ["series", "series", false]

    properties: Kirigami.FormLayout {
        QQC2.ComboBox {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("First line:")

            textRole: "label"
            valueRole: "value"
            model: [
                {
                    "label": i18n("Physical memory (B)"),
                    "value": "physical"
                },
                {
                    "label": i18n("Physical memory (%)"),
                    "value": "physical-percent"
                },
                {
                    "label": i18n("Application memory (B)"),
                    "value": "application"
                },
                {
                    "label": i18n("Application memory (%)"),
                    "value": "application-percent"
                }
            ]

            Component.onCompleted: currentIndex = indexOfValue(root.item.sensorsType[0])
            onActivated: {
                root.item.sensorsType[0] = currentValue;
                root.changed();
            }
        }

        QQC2.ComboBox {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Second line:")

            textRole: "label"
            valueRole: "value"
            model: [
                {
                    "label": i18n("Disabled"),
                    "value": "none"
                },
                {
                    "label": i18n("Swap"),
                    "value": "swap"
                },
                {
                    "label": i18n("Swap (%)"),
                    "value": "swap-percent"
                },
                {
                    "label": i18n("Memory (%)"),
                    "value": "memory-percent"
                }
            ]

            Component.onCompleted: currentIndex = indexOfValue(root.item.sensorsType[1])
            onActivated: {
                root.item.sensorsType[1] = currentValue;
                root.changed();
            }
        }

        RMControls.Thresholds {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Usage threshold:")

            values: root.item.thresholds
            onValuesChanged: {
                root.item.thresholds = values;
                root.changed();
            }

            decimals: 1
            stepSize: 1
            realFrom: 0.1
            realTo: 100
            suffix: "%"
        }
    }
}
