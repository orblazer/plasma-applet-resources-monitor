import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Dialogs as QtDialog
import org.kde.kirigami as Kirigami

RowLayout {
    id: root
    spacing: Kirigami.Units.largeSpacing

    // Aliases
    property alias dialogTitle: colorDialog.title

    // Properties
    property string value

    // Components
    QQC2.ComboBox {
        id: select
        Layout.fillWidth: true
        currentIndex: -1
        textRole: "label"
        valueRole: "value"
        model: [
            {
                "label": i18n("Custom"),
                "value": ""
            },
            {
                "label": i18nc("Colors", "Text"),
                "value": "textColor"
            },
            {
                "label": i18nc("Colors", "Highlighted text"),
                "value": "highlightedTextColor"
            },
            {
                "label": i18nc("Colors", "Link"),
                "value": "linkColor"
            },
            {
                "label": i18nc("Colors", "Visited link"),
                "value": "visitedLinkColor"
            },
            {
                "label": i18nc("Colors", "Negative text"),
                "value": "negativeTextColor"
            },
            {
                "label": i18nc("Colors", "Neutral text"),
                "value": "neutralTextColor"
            },
            {
                "label": i18nc("Colors", "Positive text"),
                "value": "positiveTextColor"
            },
            {
                "label": i18nc("Colors", "Background"),
                "value": "backgroundColor"
            },
            {
                "label": i18nc("Colors", "Highlight"),
                "value": "highlightColor"
            },
        ]

        onActivated: {
            // Open color dialog when custom
            if (currentIndex == 0) {
                colorDialog.open();
                return;
            }

            // Apply predefined color
            value = currentValue;
        }

        // Auto select predefined choice
        Component.onCompleted: {
            if (value.startsWith("#")) {
                currentIndex = 0;
            } else {
                currentIndex = indexOfValue(value);
            }
        }
    }

    Rectangle {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.height
        color: colorDialog.selectedColor
        radius: 2

        QQC2.ToolTip.visible: ma.containsMouse
        QQC2.ToolTip.text: i18nc("@info:tooltip", "Click to customize color")

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true

            onClicked: colorDialog.open()
        }
    }

    QtDialog.ColorDialog {
        id: colorDialog
        selectedColor: _resolveColor(value)
        onAccepted: {
            select.currentIndex = 0;
            value = selectedColor;
        }
    }

    function _resolveColor(value) {
        if (value.startsWith("#")) {
            return value;
        }
        return Kirigami.Theme[value] || "#000";
    }
}
