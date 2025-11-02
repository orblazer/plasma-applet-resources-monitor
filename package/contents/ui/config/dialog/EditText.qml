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

    QQC2.ComboBox {
        Layout.fillWidth: true
        Kirigami.FormData.label: i18n("Font size:")

        model: [6, 7, 8, 9, 10, 11, 12, 14, 16, 18, 20, 22, 24, 26, 28, 36, 48, 72]

        Component.onCompleted: currentIndex = indexOfValue(item.fontSize)
        onActivated: {
            item.fontSize = currentValue;
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

    // Size
    Kirigami.Separator {
        Kirigami.FormData.label: i18n("Size")
        Kirigami.FormData.isSection: true
    }
    RMControls.CustomizableSize {
        id: graphWidth
        Kirigami.FormData.label: i18n("Width:")
        Layout.fillWidth: true
        property bool isReady: false

        Component.onCompleted: {
            if (item.sizes[0] != -1) {
                value = item.sizes[0]
                customized = true
            } else {
                customized = false
            }
        }
        onValueChanged: {
            if (!isReady) return
            console.log("value", value)
            item.sizes[0] = value;
            root.changed();
        }
        onCustomizedChanged: {
            if (!isReady) return
            item.sizes[0] = customized ? value : -1
            root.changed();
        }

        spinBox {
            from: 20
            to: 1000

            onReady: isReady = true
        }
    }
    RMControls.CustomizableSize {
        id: graphHeight
        Kirigami.FormData.label: i18n("Height:")
        Layout.fillWidth: true
        property bool isReady: false

        Component.onCompleted: {
            if (item.sizes[1] != -1) {
                value = item.sizes[1]
                customized = true
            } else {
                customized = false
            }
        }
        onValueChanged: {
            if (!isReady) return
            console.log("value", value)
            item.sizes[1] = value;
            root.changed();
        }
        onCustomizedChanged: {
            if (!isReady) return
            item.sizes[1] = customized ? value : -1
            root.changed();
        }

        spinBox {
            from: 20
            to: 1000

            onReady: isReady = true
        }
    }
}
