import QtQuick 2.15
import QtQuick.Layouts 1.15 as QtLayouts
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Dialogs 1.0 as QtDialog
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami

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
        color: value.startsWith("#") ? value : theme[value]
        radius: 2
    }

    QtDialog.ColorDialog {
        id: colorDialog
        currentColor: value
        onAccepted: value = currentColor
    }
}
