import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import "./controls" as RMControls

KCM.SimpleKCM {
    // Config properties
    property alias cfg_updateInterval: updateInterval.realValue
    property var cfg_clickAction
    property alias cfg_clickActionCommand: clickActionCommand.text

    //#region // HACK: Present to suppress errors (https://bugs.kde.org/show_bug.cgi?id=484541)
    property var cfg_graphs
    property var cfg_fillPanel
    property var cfg_historyAmount
    property var cfg_customGraphWidth
    property var cfg_graphWidth
    property var cfg_customGraphHeight
    property var cfg_graphHeight
    property var cfg_graphSpacing
    property var cfg_graphFillOpacity
    property var cfg_enableShadows
    property var cfg_fontScale
    property var cfg_placement
    property var cfg_displayment
    property var cfg_warningColor
    property var cfg_criticalColor

    //#endregion

    Kirigami.FormLayout {
        RMControls.SpinBox {
            id: updateInterval
            Kirigami.FormData.label: i18n("Update interval:")
            Layout.fillWidth: true

            decimals: 1
            realFrom: 0.1
            realTo: 3600.0
            stepSize: decimalToInt(0.1)

            textFromValue: (value, locale) => i18n("%1 seconds", formatValue(value, locale))
        }

        // Click action
        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Click action")
            Kirigami.FormData.isSection: true
        }
        QQC2.ComboBox {
            id: clickAction
            Layout.fillWidth: true
            Kirigami.FormData.label: i18nc("Chart config", "Type:")

            textRole: "label"
            valueRole: "value"
            model: [
                {
                    "label": i18n("Disabled"),
                    "value": "none"
                },
                {
                    "label": i18n("Application"),
                    "value": "application"
                },
                {
                    "label": i18n("Shell command"),
                    "value": "command"
                }
            ]

            Component.onCompleted: currentIndex = indexOfValue(cfg_clickAction)
            onActivated: cfg_clickAction = currentValue
        }

        // > Button
        Loader {
            id: appSelector
            Layout.fillWidth: true
            Kirigami.FormData.label: i18nc("Chart config", "Application:")

            visible: status === Loader.Ready && clickAction.currentIndex === 1
            source: "./controls/AppSelector.qml"

            onLoaded: {
                if (cfg_clickActionCommand.startsWith("file://") && cfg_clickActionCommand.endsWidth(".desktop")) {
                    item.value = cfg_clickActionCommand;
                }
                item.valueChanged.connect(() => cfg_clickActionCommand = item.value);
            }
        }
        Kirigami.InlineMessage {
            visible: appSelector.status === Loader.Error && clickAction.currentIndex === 1
            Layout.fillWidth: true
            text: i18n("The package <i>plasma-addons</i> is required to run an application.")
            type: Kirigami.MessageType.Error
        }

        // > Command
        QQC2.TextField {
            id: clickActionCommand
            Layout.fillWidth: true
            visible: clickAction.currentIndex === 2
            Kirigami.FormData.label: i18nc("Chart config", "Command:")
        }
        Kirigami.InlineMessage {
            visible: clickActionCommand.currentIndex == 2
            Layout.fillWidth: true
            text: i18n("Command will be executed, but may have some limitations like \"<code>kioclient exec</code>\" or other similar command not work.")
            type: Kirigami.MessageType.Warning
        }
    }
}
