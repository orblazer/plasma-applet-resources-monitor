import QtQuick 2.2
import QtQuick.Controls 2.12 as QtControls
import QtQuick.Layouts 1.15 as QtLayouts
import org.kde.kirigami 2.6 as Kirigami
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import "../controls" as RMControls
import "../components" as RMComponents

PlasmaExtras.Representation {
    id: page
    anchors.fill: parent

    signal configurationChanged

    property alias cfg_verticalLayout: verticalLayout.checked
    property alias cfg_historyAmount: historyAmount.value
    property alias cfg_customGraphWidth: graphWidth.checked
    property alias cfg_graphWidth: graphWidth.value
    property alias cfg_customGraphHeight: graphHeight.checked
    property alias cfg_graphHeight: graphHeight.value
    property alias cfg_graphMargin: graphMargin.value
    property alias cfg_graphFillOpacity: graphFillOpacity.value

    property alias cfg_enableShadows: enableShadows.checked
    property alias cfg_fontScale: fontScale.value
    property string cfg_placement: ""
    property string cfg_displayment: ""

    // CPU
    property alias cfg_customCpuColor: cpuColor.checked
    property alias cfg_cpuColor: cpuColor.value
    property alias cfg_customCpuTemperatureColor: cpuTemperatureColor.checked
    property alias cfg_cpuTemperatureColor: cpuTemperatureColor.value
    // Memory
    property alias cfg_customRamColor: ramColor.checked
    property alias cfg_ramColor: ramColor.value
    property alias cfg_customSwapColor: swapColor.checked
    property alias cfg_swapColor: swapColor.value
    // Network
    property alias cfg_customNetDownColor: netDownColor.checked
    property alias cfg_netDownColor: netDownColor.value
    property alias cfg_customNetUpColor: netUpColor.checked
    property alias cfg_netUpColor: netUpColor.value
    // GPU
    property alias cfg_customGpuColor: gpuColor.checked
    property alias cfg_gpuColor: gpuColor.value
    property alias cfg_customGpuMemoryColor: gpuMemoryColor.checked
    property alias cfg_gpuMemoryColor: gpuMemoryColor.value
    property alias cfg_customGpuTemperatureColor: gpuTemperatureColor.checked
    property alias cfg_gpuTemperatureColor: gpuTemperatureColor.value
    // Disk
    property alias cfg_customDiskReadColor: diskReadColor.checked
    property alias cfg_diskReadColor: diskReadColor.value
    property alias cfg_customDiskWriteColor: diskWriteColor.checked
    property alias cfg_diskWriteColor: diskWriteColor.value
    // Threshold
    property alias cfg_customWarningColor: warningColor.checked
    property alias cfg_warningColor: warningColor.value
    property alias cfg_customCriticalColor: criticalColor.checked
    property alias cfg_criticalColor: criticalColor.value

    property color textColor: theme.textColor
    property color primaryColor: theme.highlightColor
    property color positiveColor: theme.positiveTextColor
    property color neutralColor: theme.neutralTextColor
    property color negativeColor: theme.negativeTextColor

    property var monitors: {
        "cpu": {
            "id": "cpu",
            "name": i18n("CPU Monitor"),
            "icon": "cpu-symbolic"
        },
        "memory": {
            "id": "memory",
            "name": i18n("Memory Monitor"),
            "icon": "memory-symbolic"
        },
        "gpu": {
            "id": "gpu",
            "name": i18n("GPU Monitor"),
            "icon": "freon-gpu-temperature-symbolic"
        },
        "disks": {
            "id": "disks",
            "name": i18n("Disks I/O Monitor"),
            "icon": "drive-harddisk-symbolic"
        },
        "network": {
            "id": "network",
            "name": i18n("Network Monitor"),
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
                text: i18n("Graph")
            }
            PlasmaComponents.TabButton {
                icon.name: "dialog-text-and-font"
                icon.height: PlasmaCore.Units.iconSizes.smallMedium
                text: i18n("Text")
            }
            PlasmaComponents.TabButton {
                icon.name: "color-select"
                icon.height: PlasmaCore.Units.iconSizes.smallMedium
                text: i18n("Colors")
            }
        }
    }

    QtLayouts.StackLayout {
        id: pageContent
        anchors.fill: parent
        currentIndex: bar.currentIndex

        // Graph
        Kirigami.ScrollablePage {
            Kirigami.FormLayout {
                id: graphPage
                wideMode: true

                QtControls.CheckBox {
                    id: verticalLayout
                    text: i18n("Vertical layout")
                }

                RMControls.SpinBox {
                    id: historyAmount
                    Kirigami.FormData.label: i18n("History amount:")
                    QtLayouts.Layout.fillWidth: true
                    from: 2
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
                    Kirigami.FormData.label: i18n("Graphs order")
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
                        Component.onCompleted: Plasmoid.configuration.graphOrders.map(id => monitors[id]).forEach(item => append(item))

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
                                        Plasmoid.configuration.graphOrders = graphsList.model.toJS().map(item => item.id);
                                        // To modify a StringList we need to manually trigger configurationChanged.
                                        page.configurationChanged();
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
                    textRole: "label"
                    model: [{
                            "label": i18n("Always"),
                            "name": "always"
                        }, {
                            "label": i18n("On hover"),
                            "name": "hover"
                        }, {
                            "label": i18n("Hints when hover"),
                            "name": "hover-hints"
                        }]
                    onCurrentIndexChanged: cfg_displayment = model[currentIndex]["name"]

                    Component.onCompleted: {
                        for (var i = 0; i < model.length; i++) {
                            if (model[i]["name"] === Plasmoid.configuration.displayment) {
                                displayment.currentIndex = i;
                            }
                        }
                    }
                }

                QtControls.ComboBox {
                    id: placement
                    Kirigami.FormData.label: i18n("Placement:")
                    textRole: "label"
                    model: [{
                            "label": i18n("Top left"),
                            "name": "top-left"
                        }, {
                            "label": i18n("Top right"),
                            "name": "top-right"
                        }, {
                            "label": i18n("Bottom left"),
                            "name": "bottom-left"
                        }, {
                            "label": i18n("Bottom right"),
                            "name": "bottom-right"
                        }]
                    onCurrentIndexChanged: cfg_placement = model[currentIndex]["name"]

                    Component.onCompleted: {
                        for (var i = 0; i < model.length; i++) {
                            if (model[i]["name"] === Plasmoid.configuration.placement) {
                                placement.currentIndex = i;
                            }
                        }
                    }
                }
            }
        }

        // Colors
        Kirigami.ScrollablePage {
            Kirigami.FormLayout {
                id: colorsPage

                // CPU
                Rectangle {
                    height: Kirigami.Units.largeSpacing
                    color: "transparent"
                }
                Item {
                    Kirigami.FormData.label: i18n("CPU graph colors")
                    Kirigami.FormData.isSection: true
                }

                RMControls.ColorSelector {
                    id: cpuColor
                    Kirigami.FormData.label: i18n("CPU:")

                    dialogTitle: i18n("Choose CPU graph color")
                    defaultColor: primaryColor
                }
                RMControls.ColorSelector {
                    id: cpuTemperatureColor
                    Kirigami.FormData.label: i18n("Temperature:")

                    dialogTitle: i18n("Choose CPU temperature graph color")
                    defaultColor: textColor
                }

                // Memory
                Rectangle {
                    height: Kirigami.Units.largeSpacing
                    color: "transparent"
                }
                Item {
                    Kirigami.FormData.label: i18n("Memory graph colors")
                    Kirigami.FormData.isSection: true
                }

                RMControls.ColorSelector {
                    id: ramColor
                    Kirigami.FormData.label: i18n("Physical:")

                    dialogTitle: i18n("Choose physical memory graph color")
                    defaultColor: primaryColor
                }
                RMControls.ColorSelector {
                    id: swapColor
                    Kirigami.FormData.label: i18n("Swap:")

                    dialogTitle: i18n("Choose swap memory graph color")
                    defaultColor: negativeColor
                }

                // Network
                Rectangle {
                    height: Kirigami.Units.largeSpacing
                    color: "transparent"
                }
                Item {
                    Kirigami.FormData.label: i18n("Network graph colors")
                    Kirigami.FormData.isSection: true
                }

                RMControls.ColorSelector {
                    id: netDownColor
                    Kirigami.FormData.label: i18n("Receiving:")

                    dialogTitle: i18n("Choose network receiving graph color")
                    defaultColor: primaryColor
                }
                RMControls.ColorSelector {
                    id: netUpColor
                    Kirigami.FormData.label: i18n("Sending:")

                    dialogTitle: i18n("Choose network sending graph color")
                    defaultColor: positiveColor
                }

                // GPU
                Rectangle {
                    height: Kirigami.Units.largeSpacing
                    color: "transparent"
                }
                Item {
                    Kirigami.FormData.label: i18n("GPU graph colors")
                    Kirigami.FormData.isSection: true
                }

                RMControls.ColorSelector {
                    id: gpuColor
                    Kirigami.FormData.label: i18n("Usage:")

                    dialogTitle: i18n("Choose GPU usage graph color")
                    defaultColor: primaryColor
                }
                RMControls.ColorSelector {
                    id: gpuMemoryColor
                    Kirigami.FormData.label: i18n("Memory:")

                    dialogTitle: i18n("Choose GPU memory graph color")
                    defaultColor: positiveColor
                }
                RMControls.ColorSelector {
                    id: gpuTemperatureColor
                    Kirigami.FormData.label: i18n("Temperature:")

                    dialogTitle: i18n("Choose GPU temperature graph color")
                    defaultColor: textColor
                }

                // Disk I/O
                Rectangle {
                    height: Kirigami.Units.largeSpacing
                    color: "transparent"
                }
                Item {
                    Kirigami.FormData.label: i18n("Disk I/O graph colors")
                    Kirigami.FormData.isSection: true
                }

                RMControls.ColorSelector {
                    id: diskReadColor
                    Kirigami.FormData.label: i18n("Read:")

                    dialogTitle: i18n("Choose disk read graph color")
                    defaultColor: primaryColor
                }
                RMControls.ColorSelector {
                    id: diskWriteColor
                    Kirigami.FormData.label: i18n("Write:")

                    dialogTitle: i18n("Choose disk write graph color")
                    defaultColor: positiveColor
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
                    defaultColor: neutralColor
                }
                RMControls.ColorSelector {
                    id: criticalColor
                    Kirigami.FormData.label: i18n("Critical status:")

                    dialogTitle: i18n("Choose text color when the value is in critical status")
                    defaultColor: negativeColor
                }
            }
        }
    }
}
