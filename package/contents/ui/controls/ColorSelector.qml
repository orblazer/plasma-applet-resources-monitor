import QtQuick
import QtQuick.Layouts as QtLayouts
import QtQuick.Controls as QQC2
import QtQuick.Dialogs as QtDialog
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

QtLayouts.RowLayout {
    spacing: Kirigami.Units.largeSpacing

    // Aliases
    property alias dialogTitle: colorDialog.title

    // Properties
    property string value

    // Components
    QQC2.ComboBox {
        QtLayouts.Layout.fillWidth: true
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
        QtLayouts.Layout.preferredHeight: parent.height
        QtLayouts.Layout.preferredWidth: parent.height
        color: (value.startsWith("#") ? value : Kirigami.Theme[value]) || "#000"
        radius: 2
    }

    QtDialog.ColorDialog {
        id: colorDialog
        selectedColor: value
        onAccepted: value = selectedColor
    }
}
