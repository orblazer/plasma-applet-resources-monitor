import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import "../components" as RMComponents
import "../components/functions.mjs" as Functions
import "./controls" as RMControls

KCM.SimpleKCM {
    // Config properties
    property alias cfg_updateInterval: updateInterval.realValue
    property alias cfg_clickActionCommand: clickActionCommand.text

    //#region // HACK: Present to suppress errors (https://bugs.kde.org/show_bug.cgi?id=484541)
    property var cfg_graphs
    property var cfg_verticalLayout
    property var cfg_historyAmount
    property var cfg_customGraphWidth
    property var cfg_graphWidth
    property var cfg_customGraphHeight
    property var cfg_graphHeight
    property var cfg_graphMargin
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
            minimumValue: 0.1
            maximumValue: 3600.0
            stepSize: Math.round(0.1 * factor)

            textFromValue: (value, locale) => i18n("%1 seconds", valueToText(value, locale))
        }

        // Click action
        RMControls.PredefinedTextField {
            id: clickActionCommand
            Kirigami.FormData.label: i18nc("Chart config", "Click action:")
            Layout.fillWidth: true
            customValueIndex: 1

            predefinedChoices {
                textRole: "label"
                valueRole: "value"
                model: [
                    {
                        "label": i18n("Disabled"),
                        "value": ""
                    },
                    {
                        "label": i18n("Custom command"),
                        "value": "." // Prevent collide with "disabled" state
                    },
                    {
                        "label": i18n("Open Plasma system monitor"),
                        "value": "plasma-systemmonitor"
                    }
                ]
            }
        }
        Kirigami.InlineMessage {
            visible: clickActionCommand.predefinedChoices.currentIndex == 1
            Layout.fillWidth: true
            text: i18n("Command will be executed, but may have some limitations like \"<code>kioclient exec</code>\" or other similar command not work.")
        }
    }
}
