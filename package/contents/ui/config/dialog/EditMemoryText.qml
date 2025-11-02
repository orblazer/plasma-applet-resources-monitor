import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../controls" as RMControls

/**
 * Settings format: {@link ../../code/graphs.js:64}
 */
BaseForm {
    id: root
    colorsType: ["text", "text", false]

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
    }
}
