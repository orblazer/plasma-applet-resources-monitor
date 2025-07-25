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

    QQC2.ComboBox {
        Layout.fillWidth: true
        Kirigami.FormData.label: i18n("First line:")

        textRole: "label"
        valueRole: "value"
        model: [
            {
                "label": i18n("Physical memory (in KiB)"),
                "value": "physical"
            },
            {
                "label": i18n("Physical memory (in %)"),
                "value": "physical-percent"
            },
            {
                "label": i18n("Application memory (in KiB)"),
                "value": "application"
            },
            {
                "label": i18n("Application memory (in %)"),
                "value": "application-percent"
            }
        ]

        Component.onCompleted: currentIndex = indexOfValue(item.sensorsType[0])
        onActivated: {
            item.sensorsType[0] = currentValue;
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

        value: item.colors[0]
        onValueChanged: {
            item.colors[0] = value;
            root.changed();
        }
    }
    RMControls.ColorSelector {
        Layout.fillWidth: true
        Kirigami.FormData.label: i18n("Second Line:")
        dialogTitle: i18nc("Chart color", "Choose series color")

        value: item.colors[1]
        onValueChanged: {
            item.colors[1] = value;
            root.changed();
        }
    }
}
