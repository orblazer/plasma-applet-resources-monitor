import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../controls" as RMControls

/**
 * Settings format: {@link ../../code/graphs.js:71}
 */
BaseForm {
    id: root

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
        dialogTitle: i18nc("Chart color", "Choose text color")

        value: item.colors[1]
        onValueChanged: {
            item.colors[1] = value;
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
