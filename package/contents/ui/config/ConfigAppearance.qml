import QtQuick 2.15
import QtQuick.Controls 2.15 as QtControls
import QtQuick.Layouts 1.15 as QtLayouts
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import "../controls" as RMControls
import "../components" as RMComponents

PlasmaExtras.Representation {
    id: page
    anchors.fill: parent

    // Chart
    property alias cfg_verticalLayout: verticalLayout.checked
    property alias cfg_historyAmount: historyAmount.realValue
    property alias cfg_customGraphWidth: graphWidth.customized
    property alias cfg_graphWidth: graphWidth.value
    property alias cfg_customGraphHeight: graphHeight.customized
    property alias cfg_graphHeight: graphHeight.value
    property alias cfg_graphMargin: graphMargin.value
    property alias cfg_graphFillOpacity: graphFillOpacity.value
    property var cfg_graphOrders

    // Text
    property alias cfg_enableShadows: enableShadows.checked
    property alias cfg_fontScale: fontScale.value
    property string cfg_placement
    property string cfg_displayment

    // Colors
    // > CPU
    property alias cfg_cpuColor: cpuColor.value
    property alias cfg_cpuTemperatureColor: cpuTemperatureColor.value
    // > Memory
    property alias cfg_memColor: memColor.value
    property alias cfg_memSecondColor: memSecondColor.value
    // > Network
    property alias cfg_netDownColor: netDownColor.value
    property alias cfg_netUpColor: netUpColor.value
    // > GPU
    property alias cfg_gpuColor: gpuColor.value
    property alias cfg_gpuMemoryColor: gpuMemoryColor.value
    property alias cfg_gpuTemperatureColor: gpuTemperatureColor.value
    // > Disk
    property alias cfg_diskReadColor: diskReadColor.value
    property alias cfg_diskWriteColor: diskWriteColor.value
    // > Threshold
    property alias cfg_warningColor: warningColor.value
    property alias cfg_criticalColor: criticalColor.value

    property color textColor: theme.textColor
    property color primaryColor: theme.highlightColor
    property color positiveColor: theme.positiveTextColor
    property color neutralColor: theme.neutralTextColor
    property color negativeColor: theme.negativeTextColor

    property var monitors: {
        "cpu": {
            "id": "cpu",
            "name": i18nc("Chart name", "CPU"),
            "icon": "cpu-symbolic"
        },
        "memory": {
            "id": "memory",
            "name": i18nc("Chart name", "Memory"),
            "icon": "memory-symbolic"
        },
        "gpu": {
            "id": "gpu",
            "name": i18nc("Chart name", "GPU"),
            "icon": "freon-gpu-temperature-symbolic"
        },
        "disks": {
            "id": "disks",
            "name": i18nc("Chart name", "Disks I/O"),
            "icon": "drive-harddisk-symbolic"
        },
        "network": {
            "id": "network",
            "name": i18nc("Chart name", "Network"),
            "icon": "network-wired-symbolic"
        }
    }

    // Tab bar
    header: PlasmaExtras.PlasmoidHeading {
        location: PlasmaExtras.PlasmoidHeading.Location.Header

        PlasmaComponents.TabBar {
            id: bar

            position: PlasmaComponents.TabBar.Header
            anchors.fill: parent
            implicitHeight: contentHeight

            PlasmaComponents.TabButton {
                icon.name: "office-chart-line-stacked"
                icon.height: PlasmaCore.Units.iconSizes.smallMedium
                text: i18nc("Config header", "Charts")
            }
            PlasmaComponents.TabButton {
                icon.name: "dialog-text-and-font"
                icon.height: PlasmaCore.Units.iconSizes.smallMedium
                text: i18nc("Config header", "Text")
            }
            PlasmaComponents.TabButton {
                icon.name: "color-select"
                icon.height: PlasmaCore.Units.iconSizes.smallMedium
                text: i18nc("Config header", "Colors")
            }
        }
    }

    QtLayouts.StackLayout {
        id: pageContent
        anchors.fill: parent
        currentIndex: bar.currentIndex

        // Charts
        Kirigami.ScrollablePage {
            Kirigami.FormLayout {
                id: graphPage
                wideMode: true

                QtControls.CheckBox {
                    id: verticalLayout
                    text: i18n("Vertical layout")
                }

                RMControls.PredefinedSpinBox {
                    id: historyAmount
                    Kirigami.FormData.label: i18n("History amount:")
                    QtLayouts.Layout.fillWidth: true
                    QtLayouts.Layout.minimumWidth: predefinedChoices.currentIndex == 0 ? 300 : 0

                    predefinedChoices {
                        textRole: "label"
                        valueRole: "value"
                        model: [
                            {
                                "label": i18n("Custom"),
                                "value": -1
                            },
                            {
                                "label": i18n("Disabled"),
                                "value": 0
                            },
                            {
                                "label": "10",
                                "value": 10
                            },
                            {
                                "label": "20",
                                "value": 20
                            },
                            {
                                "label": "30",
                                "value": 30
                            },
                            {
                                "label": "40",
                                "value": 40
                            },
                            {
                                "label": "50",
                                "value": 50
                            }
                        ]
                    }

                    spinBox {
                        stepSize: 1
                        minimumValue: 2
                    }
                }

                RMControls.CustomizableSize {
                    id: graphWidth
                    Kirigami.FormData.label: i18n("Width:")
                    QtLayouts.Layout.fillWidth: true
                    from: 1
                    to: 1000
                }
                RMControls.CustomizableSize {
                    id: graphHeight
                    Kirigami.FormData.label: i18n("Height:")
                    QtLayouts.Layout.fillWidth: true
                    from: 1
                    to: 1000
                }
                RMControls.SpinBox {
                    id: graphMargin
                    Kirigami.FormData.label: i18n("Margin:")
                    QtLayouts.Layout.fillWidth: true
                    from: 1
                    to: 1000

                    textFromValue: function (value, locale) {
                        return valueToText(value, locale) + " px";
                    }
                }
                RMControls.SpinBox {
                    id: graphFillOpacity
                    Kirigami.FormData.label: i18n("Fill opacity:")
                    QtLayouts.Layout.fillWidth: true
                    from: 1
                    to: 100

                    textFromValue: function (value, locale) {
                        return valueToText(value, locale) + "%";
                    }
                }

                // order
                Item {
                    Kirigami.FormData.label: i18n("Charts order")
                    Kirigami.FormData.isSection: true
                }

                ListView {
                    id: graphsList
                    anchors.left: parent.left
                    anchors.right: parent.right

                    clip: true
                    interactive: false

                    property int listViewHeight: 0
                    implicitHeight: listViewHeight

                    model: ListModel {
                        Component.onCompleted: cfg_graphOrders.map(id => monitors[id]).forEach(item => append(item))

                        function toJS() {
                            const result = [];
                            for (let i = 0; i < count; i++) {
                                result.push(get(i));
                            }
                            return result;
                        }
                    }

                    delegate: Kirigami.DelegateRecycler {
                        width: graphsList.width
                        sourceComponent: delegateComponent

                        Component.onCompleted: {
                            graphsList.listViewHeight += height + 1;
                        }
                    }

                    moveDisplaced: Transition {
                        YAnimator {
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Component {
                        id: delegateComponent
                        Kirigami.AbstractListItem {
                            id: listItem

                            backgroundColor: theme.headerBackgroundColor
                            separatorVisible: true

                            contentItem: QtLayouts.RowLayout {
                                spacing: Kirigami.Units.largeSpacing

                                Kirigami.ListItemDragHandle {
                                    listView: graphsList
                                    listItem: listItem
                                    onMoveRequested: graphsList.model.move(oldIndex, newIndex, 1)

                                    onDropped: {
                                        cfg_graphOrders = graphsList.model.toJS().map(item => item.id);
                                    }
                                }

                                PlasmaCore.IconItem {
                                    source: model.icon
                                    width: PlasmaCore.Units.iconSizes.smallMedium
                                    height: width
                                }
                                PlasmaComponents.Label {
                                    text: model.name
                                    QtLayouts.Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }

        // Text
        Kirigami.ScrollablePage {
            Kirigami.FormLayout {
                id: textPage
                wideMode: true

                QtControls.CheckBox {
                    id: enableShadows
                    text: i18n("Drop shadows")
                }

                RMControls.SpinBox {
                    id: fontScale
                    Kirigami.FormData.label: i18n("Font scale:")
                    QtLayouts.Layout.fillWidth: true
                    from: 1
                    to: 100

                    textFromValue: function (value, locale) {
                        return valueToText(value, locale) + "%";
                    }
                }

                QtControls.ComboBox {
                    id: displayment
                    Kirigami.FormData.label: i18n("Text displayment:")

                    currentIndex: -1
                    textRole: "label"
                    valueRole: "name"
                    model: [
                        {
                            "label": i18nc("Text displayment", "Always"),
                            "name": "always"
                        },
                        {
                            "label": i18nc("Text displayment", "On hover"),
                            "name": "hover"
                        },
                        {
                            "label": i18nc("Text displayment", "Hints when hover"),
                            "name": "hover-hints"
                        },
                        {
                            "label": i18nc("Text displayment", "Never"),
                            "name": "never"
                        }
                    ]

                    onActivated: cfg_displayment = currentValue
                    Component.onCompleted: currentIndex = indexOfValue(cfg_displayment)
                }

                QtControls.ComboBox {
                    id: placement
                    Kirigami.FormData.label: i18n("Placement:")

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
                        }
                    ]

                    onActivated: cfg_placement = currentValue
                    Component.onCompleted: currentIndex = indexOfValue(cfg_placement)
                }
            }
        }

        // Colors
        Kirigami.ScrollablePage {
            Kirigami.FormLayout {
                id: colorsPage

                // Charts
                Kirigami.Separator {
                    Kirigami.FormData.label: i18n("Charts colors")
                    Kirigami.FormData.isSection: true
                }

                // > CPU
                Rectangle {
                    height: Kirigami.Units.largeSpacing
                    color: "transparent"
                }
                Item {
                    Kirigami.FormData.label: i18nc("Chart name", "CPU")
                    Kirigami.FormData.isSection: true
                }

                RMControls.ColorSelector {
                    id: cpuColor
                    Kirigami.FormData.label: i18nc("Chart config", "Usage:")
                    dialogTitle: i18nc("Chart color", "Choose series color")
                }
                RMControls.ColorSelector {
                    id: cpuTemperatureColor
                    Kirigami.FormData.label: i18nc("Chart config", "Temperature:")
                    dialogTitle: i18nc("Chart color", "Choose text color")
                }

                // > Memory
                Rectangle {
                    height: Kirigami.Units.largeSpacing
                    color: "transparent"
                }
                Item {
                    Kirigami.FormData.label: i18nc("Chart name", "Memory")
                    Kirigami.FormData.isSection: true
                }

                RMControls.ColorSelector {
                    id: memColor
                    Kirigami.FormData.label: i18nc("Chart config", "Physical:")
                    dialogTitle: i18nc("Chart color", "Choose series color")
                }
                RMControls.ColorSelector {
                    id: memSecondColor
                    Kirigami.FormData.label: i18nc("Chart config", "Swap:")
                    dialogTitle: i18nc("Chart color", "Choose color of series and text")
                }

                // > Network
                Rectangle {
                    height: Kirigami.Units.largeSpacing
                    color: "transparent"
                }
                Item {
                    Kirigami.FormData.label: i18nc("Chart name", "Network")
                    Kirigami.FormData.isSection: true
                }

                RMControls.ColorSelector {
                    id: netDownColor
                    Kirigami.FormData.label: i18nc("Chart config", "Receiving:")
                    dialogTitle: i18nc("Chart color", "Choose series color")
                }
                RMControls.ColorSelector {
                    id: netUpColor
                    Kirigami.FormData.label: i18nc("Chart config", "Sending:")
                    dialogTitle: i18nc("Chart color", "Choose series color")
                }

                // > GPU
                Rectangle {
                    height: Kirigami.Units.largeSpacing
                    color: "transparent"
                }
                Item {
                    Kirigami.FormData.label: i18nc("Chart name", "GPU")
                    Kirigami.FormData.isSection: true
                }

                RMControls.ColorSelector {
                    id: gpuColor
                    Kirigami.FormData.label: i18nc("Chart config", "Usage:")
                    dialogTitle: i18nc("Chart color", "Choose series color")
                }
                RMControls.ColorSelector {
                    id: gpuMemoryColor
                    Kirigami.FormData.label: i18nc("Chart config", "Memory:")
                    dialogTitle: i18nc("Chart color", "Choose series color")
                }
                RMControls.ColorSelector {
                    id: gpuTemperatureColor
                    Kirigami.FormData.label: i18nc("Chart config", "Temperature:")
                    dialogTitle: i18nc("Chart color", "Choose text color")
                }

                // > Disk I/O
                Rectangle {
                    height: Kirigami.Units.largeSpacing
                    color: "transparent"
                }
                Item {
                    Kirigami.FormData.label: i18nc("Chart name", "Disks I/O")
                    Kirigami.FormData.isSection: true
                }

                RMControls.ColorSelector {
                    id: diskReadColor
                    Kirigami.FormData.label: i18nc("Chart config", "Read:")
                    dialogTitle: i18nc("Chart color", "Choose series color")
                }
                RMControls.ColorSelector {
                    id: diskWriteColor
                    Kirigami.FormData.label: i18nc("Chart config", "Write:")
                    dialogTitle: i18nc("Chart color", "Choose series color")
                }

                // Thresholds
                Kirigami.Separator {
                    Kirigami.FormData.label: i18n("Threshold text colors")
                    Kirigami.FormData.isSection: true
                }

                RMControls.ColorSelector {
                    id: warningColor
                    Kirigami.FormData.label: i18n("Warning status:")
                    dialogTitle: i18n("Choose text color when the value is in warning status")
                }
                RMControls.ColorSelector {
                    id: criticalColor
                    Kirigami.FormData.label: i18n("Critical status:")
                    dialogTitle: i18n("Choose text color when the value is in critical status")
                }
            }
        }
    }
}
