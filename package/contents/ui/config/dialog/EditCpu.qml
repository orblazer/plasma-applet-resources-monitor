import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../controls" as RMControls

/**
 * Settings format: {@link ../../code/graphs.js:8}
 */
BaseForm {
    id: root
    colorsType: ["series", "text", "text"]

    properties: Kirigami.FormLayout {
        QQC2.ComboBox {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("First line:")

            textRole: "label"
            valueRole: "value"
            model: [
                {
                    "label": i18n("Total usage"),
                    "value": "usage"
                },
                {
                    "label": i18n("System usage"),
                    "value": "system"
                },
                {
                    "label": i18n("User usage"),
                    "value": "user"
                }
            ]

            Component.onCompleted: currentIndex = indexOfValue(root.item.sensorsType[0])
            onActivated: {
                root.item.sensorsType[0] = currentValue;
                root.changed();
            }
        }

        // Clock
        QQC2.ComboBox {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Second Line:")

            textRole: "label"
            valueRole: "value"
            model: [
                {
                    "label": i18n("Disabled"),
                    "value": "none"
                },
                {
                    "label": i18n("Classic/P-cores clock frequency"),
                    "value": "classic"
                },
                {
                    "label": i18n("E-cores clock frequency"),
                    "value": "ecores"
                }
            ]

            Component.onCompleted: currentIndex = indexOfValue(root.item.sensorsType[1])
            onActivated: {
                root.item.sensorsType[1] = currentValue;
                root.changed();
            }
        }
        QQC2.ComboBox {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Clock aggregator:")

            textRole: "label"
            valueRole: "value"
            model: [
                {
                    "label": i18nc("Aggregator", "Average"),
                    "value": "average"
                },
                {
                    "label": i18nc("Aggregator", "Minimum"),
                    "value": "minimum"
                },
                {
                    "label": i18nc("Aggregator", "Maximum"),
                    "value": "maximum"
                }
            ]

            Component.onCompleted: currentIndex = indexOfValue(root.item.clockAggregator)
            onActivated: {
                root.item.clockAggregator = currentValue;
                root.changed();
            }
        }
        // Define Number of E-Cores, it's used for separating Intel
        // E-cores and P-Cores when calculating CPU frequency,
        // because they have different frequencies.
        RMControls.SpinBox {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("E-cores")
            from: 0
            to: 100

            realValue: root.item.eCoresCount
            onRealValueChanged: {
                root.item.eCoresCount = value;
                root.changed();
            }

            QQC2.ToolTip.text: i18nc("@info:tooltip", "<b>For Intel gen 12+ only</b><br>Number of E-Cores your CPU have, it's for separate it from P-Cores in clock frequency average calculation.")
            QQC2.ToolTip.visible: hovered
        }

        QQC2.CheckBox {
            text: i18n("Show temperature")
            checked: root.item.sensorsType[2]
            onClicked: {
                root.item.sensorsType[2] = checked;
                root.changed();
            }
        }

        RMControls.Thresholds {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Temperature threshold:")

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
