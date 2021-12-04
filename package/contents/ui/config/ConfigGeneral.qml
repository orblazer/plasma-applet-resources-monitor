import QtQuick 2.2
import QtQuick.Controls 2.12 as QtControls
import QtQuick.Layouts 1.1 as QtLayouts
import org.kde.kirigami 2.6 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "../components" as RMComponents
import "../controls" as RMControls

QtLayouts.ColumnLayout {
    id: page

    signal configurationChanged

    property alias cfg_updateInterval: updateInterval.valueReal
    property string cfg_networkUnit: plasmoid.configuration.networkUnit
    property string cfg_actionService: plasmoid.configuration.actionService

    property alias cfg_showCpuMonitor: showCpuMonitor.checked
    property alias cfg_showClock: showClock.checked
    property alias cfg_showRamMonitor: showRamMonitor.checked
    property alias cfg_memoryInPercent: memoryInPercent.checked
    property alias cfg_showNetMonitor: showNetMonitor.checked

    // Apps model
    RMComponents.AppsDetector {
        id: appsModel
        filterCallback: function (index, value) {
            var search = appsFilter.text.toLowerCase()

            if (value.toLowerCase().indexOf(search) !== -1) {
                return true
            }
            if (datasource.get(index).menuId.replace(".desktop", "").toLowerCase().indexOf(search) !== -1) {
                return true
            }
            return false
        }
    }

    // Tab bar
    PlasmaComponents.TabBar {
        id: bar

        PlasmaComponents.TabButton {
            tab: generalPage
            iconSource: "preferences-system-windows"
            text: i18n("General")
        }
        PlasmaComponents.TabButton {
            tab: clickPage
            iconSource: "input-mouse-click-left"
            text: i18n("Click action")
        }
    }

    // Views
    PlasmaComponents.TabGroup {
        QtLayouts.Layout.fillWidth: true
        QtLayouts.Layout.fillHeight: true

        // General
        QtLayouts.ColumnLayout {
            id: generalPage
            spacing: Kirigami.Units.largeSpacing

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

                QtControls.ComboBox {
                    id: networkUnit
                    Kirigami.FormData.label: i18n("Network speed unit:")
                    textRole: "label"
                    model: [{
                        label: i18n("Kibibyte (KiB/s)"),
                        value: "kibibyte"
                    }, {
                        label: i18n("Kilobit (Kbps)"),
                        value: "kilobit"
                    }, {
                        label: i18n("Kilobyte (KBps)"),
                        value: "kilobyte"
                    }]

                    onCurrentIndexChanged: {
                        var current = model[currentIndex]
                        if (current && current.value !== -1) {
                            if (current.value !== cfg_networkUnit) {
                                cfg_networkUnit = current.value
                                page.configurationChanged()
                            }
                        }
                    }

                    Component.onCompleted: {
                        for (var i = 0; i < model.length; i++) {
                            if (model[i]["value"] === cfg_networkUnit) {
                                currentIndex = i;
                                return
                            }
                        }
                    }
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

        // CLick action
        QtLayouts.ColumnLayout {
            id: clickPage
            spacing: Kirigami.Units.largeSpacing

            Kirigami.FormLayout {
                wideMode: true

                QtControls.TextField {
                    id: appsFilter
                    Kirigami.FormData.label: i18n("Search an application:")
                    QtLayouts.Layout.fillWidth: true
                    placeholderText: i18n("Application name")

                    onTextChanged: appsList.updateCurrentIndex()
                }
            }

            // Apps list
            PlasmaComponents.Label {
                text: i18n("Applications")
                font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.2
            }

            Item {
                QtLayouts.Layout.fillWidth: true
                QtLayouts.Layout.fillHeight: true

                Rectangle {
                    anchors.fill: parent
                    color: theme.headerBackgroundColor
                    border.color: theme.complementaryBackgroundColor
                    border.width: 1
                    radius: 4
                }

                PlasmaExtras.ScrollArea {
                    anchors.fill: parent
                    anchors.margins: 10
                    anchors.rightMargin: 5

                    ListView {
                        id: appsList

                        model: appsModel
                        clip: true

                        highlight: PlasmaComponents.Highlight {
                        }
                        highlightMoveDuration: 0
                        highlightMoveVelocity: -1

                        delegate: RMComponents.ApplicationDelegateItem {
                            width: root.width

                            serviceName: model.menuId.replace(".desktop", "")
                            name: model.name
                            comment: model.comment
                            iconName: model.iconName
                            selected: ListView.isCurrentItem

                            onClicked: {
                                appsList.currentIndex = index

                                var oldValue = cfg_actionService
                                cfg_actionService = serviceName
                                if (cfg_actionService !== oldValue) {
                                    page.configurationChanged()
                                }
                            }
                        }

                        Component.onCompleted: updateCurrentIndex()

                        function updateCurrentIndex() {
                            for (var i = 0; i < model.count; i++) {
                                if (model.get(i).menuId === cfg_actionService + ".desktop") {
                                    currentIndex = i
                                    return
                                }
                            }
                            currentIndex = -1
                        }
                    }
                }
            }
        }
    }
}
