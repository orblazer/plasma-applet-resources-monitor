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

    QQC2.TextField {
        id: textField
        text: item.device
        Layout.fillWidth: true
        Kirigami.FormData.label: i18n("Value:")

        onTextChanged: {
            item.device = text;
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

        onActivated: item.placement = currentValue
        Component.onCompleted: currentIndex = indexOfValue(item.placement)
    }

    RMControls.SpinBox {
        id: fontScale
        Kirigami.FormData.label: i18n("Font scale:")
        Layout.fillWidth: true
        from: 1
        to: 100
        suffix: "%"

        value: item.size
        onValueChanged: {
            item.size = value;
            root.changed();
        }
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

        value: item.color
        onValueChanged: {
            item.color = value;
            root.changed();
        }
    }
}
