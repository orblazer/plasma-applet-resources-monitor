import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../controls" as RMControls

/**
 * Settings format: {@link ../../code/graphs.js:71}
 */
BaseForm {
    id: root
    colorsType: ["text", "text", false]

    properties: Kirigami.FormLayout {
        QQC2.ComboBox {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("First Line:")

            currentIndex: -1
            textRole: "label"
            valueRole: "value"
            model: [
                {
                    "label": i18n("Usage (%)"),
                    "value": "usage"
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
    }
}
