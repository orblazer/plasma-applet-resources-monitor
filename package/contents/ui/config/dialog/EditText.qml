import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../controls" as RMControls

/**
 * Settings format: {@link ../../code/graphs.js:88}
 */
BaseForm {
    id: root
    colorsType: ["text", false, false]

    properties: Kirigami.FormLayout {
        QQC2.TextField {
            id: textField
            text: root.item.device
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Value:")

            onTextChanged: {
                root.item.device = text;
                root.changed();
            }
        }

        QQC2.ComboBox {
            id: placement
            Kirigami.FormData.label: i18n("Placement:")
            Layout.fillWidth: true

            currentIndex: -1
            textRole: "label"
            valueRole: "name"
            model: [
                {
                    "label": i18nc("Text placement", "Top left"),
                    "name": "top-left"
                },
                {
                    "label": i18nc("Text placement", "Top right"),
                    "name": "top-right"
                },
                {
                    "label": i18nc("Text placement", "Bottom left"),
                    "name": "bottom-left"
                },
                {
                    "label": i18nc("Text placement", "Bottom right"),
                    "name": "bottom-right"
                },
                {
                    "label": i18nc("Text placement", "Middle left"),
                    "name": "middle-left"
                },
                {
                    "label": i18nc("Text placement", "Middle right"),
                    "name": "middle-right"
                },
            ]

            onActivated: root.item.placement = currentValue
            Component.onCompleted: currentIndex = indexOfValue(root.item.placement)
        }

        QQC2.ComboBox {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Font size:")

            model: [6, 7, 8, 9, 10, 11, 12, 14, 16, 18, 20, 22, 24, 26, 28, 36, 48, 72]

            Component.onCompleted: currentIndex = indexOfValue(root.item.fontSize)
            onActivated: {
                root.item.fontSize = currentValue;
                root.changed();
            }
        }
    }
}
