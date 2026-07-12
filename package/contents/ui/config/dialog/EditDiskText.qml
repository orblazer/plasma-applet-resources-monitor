import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../controls" as RMControls

/**
 * Settings format: {@link ../../code/graphs.js}
 */
BaseForm {
    id: root
    colorsType: ["text", "text", false]

    properties: Kirigami.FormLayout {
        QQC2.TextField {
            id: textField
            text: root.item.title
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Title:")

            onTextChanged: {
                root.item.title = text;
                root.changed();
            }
        }

        // First line
        QQC2.ComboBox {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("First line:")

            textRole: "label"
            valueRole: "value"
            model: [
                {
                    "label": i18n("Disk usage (B)"),
                    "value": "used"
                },
                {
                    "label": i18n("Disk usage (%)"),
                    "value": "used-percent"
                }
            ]

            Component.onCompleted: currentIndex = indexOfValue(root.item.sensorsType[0])
            onActivated: {
                root.item.sensorsType[0] = currentValue;
                root.changed();
            }
        }
    }

    appearanceProperties: Kirigami.FormLayout {
        QQC2.ComboBox {
            id: displayment
            Kirigami.FormData.label: i18n("Title when:")
            Layout.fillWidth: true

            currentIndex: -1
            textRole: "label"
            valueRole: "name"
            model: [
                {
                    "label": i18nc("Text display", "Always"),
                    "name": "always"
                },
                {
                    "label": i18nc("Text display", "Hints when hover"),
                    "name": "hints"
                },
                {
                    "label": i18nc("Text display", "Never"),
                    "name": "never"
                }
            ]

            Component.onCompleted: currentIndex = indexOfValue(root.item.titleWhen)
            onActivated: {
                root.item.titleWhen = currentValue;
                root.changed();
            }
        }
    }
}
