import QtQuick 2.2
import QtQuick.Controls 2.12 as QtControls
import QtQuick.Layouts 1.1 as QtLayouts
import org.kde.kirigami 2.6 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "../controls" as RMControls

QtLayouts.ColumnLayout {
    spacing: Kirigami.Units.largeSpacing

    property alias cfg_updateInterval: updateInterval.valueReal
    property alias cfg_actionService: customActionService.text

    property alias cfg_showCpuMonitor: showCpuMonitor.checked
    property alias cfg_showClock: showClock.checked
    property alias cfg_showRamMonitor: showRamMonitor.checked
    property alias cfg_memoryInPercent: memoryInPercent.checked
    property alias cfg_showNetMonitor: showNetMonitor.checked

    // TODO: find way to use `.desktop` transltation for programs
    readonly property var actionServiceOptions: [
        {
            "label": i18n("Custom"),
            "value": ""
        }, {
            "label": i18n("Plasma System Monitor"),
            "value": "org.kde.plasma-systemmonitor"
        }, {
            "label": "KSysGuard",
            "value": "org.kde.ksysguard"
        }, {
            "label": i18n("System Monitor"),
            "value": "org.kde.systemmonitor"
        }
    ]


    Kirigami.FormLayout {
        wideMode: true

        RMControls.SpinBox {
            id: updateInterval
            Kirigami.FormData.label: i18n("Update interval:")
            QtLayouts.Layout.fillWidth: true

            decimals: 1
            minimumValue: 0.1
            maximumValue: 3600.0
            stepSize: Math.round(0.1 * factor)

            textFromValue: function(value) {
                return i18n("%1 seconds", valueToText(value))
            }
        }

        // click action
        PlasmaComponents.Label {
            text: i18n("Click action")
            font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.2
        }

        QtControls.ComboBox {
            id: actionService
            Kirigami.FormData.label: i18n("Program:")
            textRole: "label"
            model: actionServiceOptions
            QtLayouts.Layout.fillWidth: true

            onCurrentIndexChanged: {
                var current = model[currentIndex]
                if (current && current.value !== "") {
                    customActionService.text = current.value
                }
            }

            Component.onCompleted: {
                for (var i = 0; i < model.length; i++) {
                    if (model[i]["value"] === plasmoid.configuration.actionService) {
                        actionService.currentIndex = i;
                        return
                    }
                }

                actionService.currentIndex = 0 // Custom
            }
        }
        QtControls.TextField {
            id: customActionService
            Kirigami.FormData.label: i18n("Custom program:")
            QtLayouts.Layout.fillWidth: true
            visible: actionService.currentIndex === 0
        }
        PlasmaComponents.Label {
            text: i18n("NOTE: The is name should same as filename\nin \"%1\"", "/usr/share/applications/")
        }
    }

    // Charts
    PlasmaComponents.Label {
        text: i18n("Charts")
        font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.2
    }

    QtLayouts.GridLayout {
        QtLayouts.Layout.fillWidth: true
        columns: 2
        rowSpacing: Kirigami.Units.smallSpacing
        columnSpacing: Kirigami.Units.largeSpacing

        // CPU
        QtControls.CheckBox {
            id: showCpuMonitor
            text: i18n("Show CPU monitor")
        }
        QtControls.CheckBox {
            id: showClock
            text: i18n("Show CPU clock")
            enabled: showCpuMonitor.checked
        }

        // Memory
        QtControls.CheckBox {
            id: showRamMonitor
            text: i18n("Show memory monitor")
        }
        QtControls.CheckBox {
            id: memoryInPercent
            text: i18n("Memory in percentage")
            enabled: showRamMonitor.checked
        }

        QtControls.CheckBox {
            id: showNetMonitor
            text: i18n("Show network monitor")
        }
    }

    Item {
        QtLayouts.Layout.fillWidth: true
        QtLayouts.Layout.fillHeight: true
    }
}
