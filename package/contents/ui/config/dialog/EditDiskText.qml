import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

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
            enabled: !root.item.sensorsType[0].includes("io")

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
                    "label": i18n("Usage (B)"),
                    "value": "used"
                },
                {
                    "label": i18n("Usage (%)"),
                    "value": "used-percent"
                },
                {
                    "label": i18n("I/O (R/W)"),
                    "value": "io"
                },
                {
                    "label": i18n("I/O inverted (W/R)"),
                    "value": "io-reverse"
                }
            ]

            Component.onCompleted: currentIndex = indexOfValue(root.item.sensorsType[0])
            onActivated: {
                root.item.sensorsType[0] = currentValue
                textField.enabled = !currentValue.includes("io")
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

        QQC2.CheckBox {
            text: i18n("Show icons (%1 / %2)", i18nc("Disk graph icon : Read", "R"), i18nc("Disk graph icon : Write", "W"))
            checked: root.item.icons
            onClicked: {
                root.item.icons = checked;
                root.changed();
            }
        }
    }
}
