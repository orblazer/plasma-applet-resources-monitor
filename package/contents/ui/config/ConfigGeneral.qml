import QtQuick 2.15
import QtQuick.Controls 2.15 as QtControls
import QtQuick.Layouts 1.15 as QtLayouts
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import "../components" as RMComponents
import "../controls" as RMControls

PlasmaExtras.Representation {
    id: page
    anchors.fill: parent

    // Charts
    property alias cfg_updateInterval: updateInterval.realValue
    // > CPU
    property bool cfg_showCpuMonitor
    property string cfg_cpuUnit
    property bool cfg_showClock
    property string cfg_clockAgregator
    property alias cfg_showCpuTemperature: showCpuTemperature.checked
    // > Memory
    property bool cfg_showRamMonitor
    property string cfg_memoryUnit
    property string cfg_memorySecondUnit
    property bool cfg_memorySwapGraph
    // > Network
    property bool cfg_showNetMonitor
    property string cfg_networkUnit
    // > GPU
    property alias cfg_showGpuMonitor: showGpuMonitor.checked
    property alias cfg_gpuMemoryInPercent: gpuMemoryInPercent.checked
    property alias cfg_gpuMemoryGraph: gpuMemoryGraph.checked
    property alias cfg_showGpuTemperature: showGpuTemperature.checked
    // > Disks I/O
    property alias cfg_showDiskMonitor: showDiskMonitor.checked

    // Click action
    property string cfg_actionService

    // Apps model
    RMComponents.AppsDetector {
        id: appsModel

        filterString: appsFilter.text
        filterCallback: function (index, value) {
            var search = filterString.toLowerCase();
            if (search.length === 0) {
                return true;
            }
            if (value.toLowerCase().indexOf(search) !== -1) {
                return true;
            }
            if (sourceModel.get(index).menuId.replace(".desktop", "").toLowerCase().indexOf(search) !== -1) {
                return true;
            }
            return false;
        }

        onFilterStringChanged: appsList.updateCurrentIndex()
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
                icon.name: "settings"
                icon.height: PlasmaCore.Units.iconSizes.smallMedium
                text: i18nc("Config header", "General")
            }
            PlasmaComponents.TabButton {
                icon.name: "input-mouse-symbolic"
                icon.height: PlasmaCore.Units.iconSizes.smallMedium
                text: i18nc("Config header", "Click action")
            }
        }
    }

    QtLayouts.StackLayout {
        id: pageContent
        anchors.fill: parent
        currentIndex: bar.currentIndex

        // General
        Kirigami.ScrollablePage {
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

                    textFromValue: function (value, locale) {
                        return i18n("%1 seconds", valueToText(value, locale));
                    }
                }

                // Charts
                Kirigami.Separator {
                    Kirigami.FormData.label: i18nc("Config header", "Charts")
                    Kirigami.FormData.isSection: true
                }

                // CPU
                Item {
                    Kirigami.FormData.label: i18nc("Chart name", "CPU")
                    Kirigami.FormData.isSection: true
                }

                QtControls.ComboBox {
                    QtLayouts.Layout.fillWidth: true
                    Kirigami.FormData.label: i18n("Visibility:")

                    currentIndex: -1
                    textRole: "label"
                    valueRole: "value"
                    model: [
                        {
                            "label": i18n("Disabled"),
                            "value": "none"
                        },
                        {
                            "label": i18n("Total usage"),
                            "value": "usage"
                        },
                        {
                            "label": i18n("System usage"),
                            "value": "system"
                        },
                        {
                            "label": i18n("User usage"),
                            "value": "user"
                        }
                    ]

                    onActivated: {
                        if (currentValue === "none") {
                            cfg_showCpuMonitor = false;
                        } else {
                            cfg_showCpuMonitor = true;
                            cfg_cpuUnit = currentValue;
                        }
                    }
                    Component.onCompleted: {
                        // TODO (3.0): Merge "cfg_showCpuMonitor" and "cfg_cpuUnit"
                        currentIndex = cfg_showCpuMonitor ? indexOfValue(cfg_cpuUnit) : 0;
                    }
                }

                QtControls.ComboBox {
                    QtLayouts.Layout.fillWidth: true
                    Kirigami.FormData.label: i18n("Clock visibility:")
                    enabled: cfg_showCpuMonitor

                    currentIndex: -1
                    textRole: "label"
                    valueRole: "value"
                    model: [
                        {
                            "label": i18n("Disabled"),
                            "value": "none"
                        },
                        {
                            "label": i18nc("Agregator", "Average"),
                            "value": "average"
                        },
                        {
                            "label": i18nc("Agregator", "Minimum"),
                            "value": "minimum"
                        },
                        {
                            "label": i18nc("Agregator", "Maximum"),
                            "value": "maximum"
                        }
                    ]

                    onActivated: {
                        if (currentValue === "none") {
                            cfg_showClock = false;
                        } else {
                            cfg_showClock = true;
                            cfg_clockAgregator = currentValue;
                        }
                    }
                    Component.onCompleted: {
                        // TODO (3.0): Merge "cfg_showClock" and "cfg_clockAgregator"
                        currentIndex = cfg_showClock ? indexOfValue(cfg_clockAgregator) : 0;
                    }
                }

                QtControls.CheckBox {
                    id: showCpuTemperature
                    text: i18n("Show temperature")
                    enabled: cfg_showCpuMonitor
                }

                // Memory
                Rectangle {
                    height: Kirigami.Units.largeSpacing
                    color: "transparent"
                }
                Item {
                    Kirigami.FormData.label: i18nc("Chart name", "Memory")
                    Kirigami.FormData.isSection: true
                }

                QtControls.ComboBox {
                    QtLayouts.Layout.fillWidth: true
                    Kirigami.FormData.label: i18n("Visibility:")

                    currentIndex: -1
                    textRole: "label"
                    valueRole: "value"
                    model: [
                        {
                            "label": i18n("Disabled"),
                            "value": "none"
                        },
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

                    onActivated: {
                        if (currentValue === "none") {
                            cfg_showRamMonitor = false;
                        } else {
                            cfg_showRamMonitor = true;
                            cfg_memoryUnit = currentValue;
                        }

                        // TODO (3.0): Remove this
                        // Sync swap show in percent or not (legacy behavior)
                        if (currentValue.endsWith("-percent") && memorySecondLine.currentIndex == 1) {
                            plasmoid.configuration.memorySecondUnit = cfg_memorySecondUnit = "swap-percent";
                            memorySecondLine.currentIndex = 2;
                        } else if (!currentValue.endsWith("-percent") && memorySecondLine.currentIndex == 2) {
                            plasmoid.configuration.memorySecondUnit = cfg_memorySecondUnit = "swap";
                            memorySecondLine.currentIndex = 1;
                        }

                    }
                    Component.onCompleted: {
                        // TODO (3.0): Merge "cfg_showRamMonitor" and "cfg_memoryUnit"
                        currentIndex = cfg_showRamMonitor ? indexOfValue(cfg_memoryUnit) : 0;
                    }
                }

                QtControls.ComboBox {
                    id: memorySecondLine
                    QtLayouts.Layout.fillWidth: true
                    Kirigami.FormData.label: i18n("Second line:")
                    enabled: cfg_showRamMonitor

                    currentIndex: -1
                    textRole: "label"
                    valueRole: "value"
                    model: [
                        {
                            "label": i18n("Disabled"),
                            "value": "none"
                        },
                        {
                            "label": i18n("Swap"),
                            "value": "swap"
                        },
                        {
                            "label": i18n("Swap (in %)"),
                            "value": "swap-percent"
                        },
                        {
                            "label": i18n("Memory (in %)"),
                            "value": "percent"
                        }
                    ]

                    onActivated: {
                        if (currentValue === "none") {
                            cfg_memorySwapGraph = false;
                            cfg_memorySecondUnit = "none";
                        } else if (currentValue === "swap") {
                            cfg_memorySwapGraph = true;
                            cfg_memorySecondUnit = "swap";
                        } else if (currentValue === "swap-percent") {
                            cfg_memorySwapGraph = true;
                            cfg_memorySecondUnit = "swap-percent";
                        } else {
                            cfg_memorySwapGraph = false;
                            cfg_memorySecondUnit = currentValue;
                        }
                    }
                    Component.onCompleted: {
                        // TODO (3.0): Remove this legacy load
                        if (cfg_memorySecondUnit == "") {
                            if (cfg_memorySwapGraph && cfg_memoryUnit.endsWith("-percent")) {
                                currentIndex = 2;
                            } else {
                                currentIndex = Number(cfg_memorySwapGraph);
                            }
                            return;
                        }
                        currentIndex = indexOfValue(cfg_memorySecondUnit);
                    }
                }

                // Network
                Rectangle {
                    height: Kirigami.Units.largeSpacing
                    color: "transparent"
                }
                Item {
                    Kirigami.FormData.label: i18nc("Chart name", "Network")
                    Kirigami.FormData.isSection: true
                }

                QtControls.ComboBox {
                    QtLayouts.Layout.fillWidth: true
                    Kirigami.FormData.label: i18n("Visibility:")

                    currentIndex: -1
                    textRole: "label"
                    valueRole: "value"
                    model: [
                        {
                            "label": i18n("Disabled"),
                            "value": "none"
                        },
                        {
                            "label": i18n("In kibibyte (KiB/s)"),
                            "value": "kibibyte"
                        },
                        {
                            "label": i18n("In kilobit (Kbps)"),
                            "value": "kilobit"
                        },
                        {
                            "label": i18n("In kilobyte (KBps)"),
                            "value": "kilobyte"
                        }
                    ]

                    onActivated: {
                        if (currentValue === "none") {
                            cfg_showNetMonitor = false;
                        } else {
                            cfg_showNetMonitor = true;
                            cfg_networkUnit = currentValue;
                        }
                    }
                    Component.onCompleted: {
                        // TODO (3.0): Merge "cfg_showNetMonitor" and "cfg_networkUnit"
                        currentIndex = cfg_showNetMonitor ? indexOfValue(cfg_networkUnit) : 0;
                    }
                }

                // GPU
                Rectangle {
                    height: Kirigami.Units.largeSpacing
                    color: "transparent"
                }
                Item {
                    Kirigami.FormData.label: i18nc("Chart name", "GPU")
                    Kirigami.FormData.isSection: true
                }

                QtLayouts.GridLayout {
                    QtLayouts.Layout.fillWidth: true
                    columns: 2
                    rowSpacing: Kirigami.Units.smallSpacing
                    columnSpacing: Kirigami.Units.largeSpacing

                    QtControls.CheckBox {
                        id: showGpuMonitor
                        text: i18n("Enabled?")
                    }
                    QtControls.CheckBox {
                        id: gpuMemoryGraph
                        text: i18n("Show memory")
                        enabled: showGpuMonitor.checked
                    }
                    QtControls.CheckBox {
                        id: gpuMemoryInPercent
                        text: i18n("Memory in percent")
                        enabled: showGpuMonitor.checked
                    }
                    QtControls.CheckBox {
                        id: showGpuTemperature
                        text: i18n("Show temperature")
                        enabled: showGpuMonitor.checked
                    }
                }

                // Disk I/O
                Rectangle {
                    height: Kirigami.Units.largeSpacing
                    color: "transparent"
                }
                Item {
                    Kirigami.FormData.label: i18nc("Chart name", "Disks I/O")
                    Kirigami.FormData.isSection: true
                }

                QtLayouts.GridLayout {
                    QtLayouts.Layout.fillWidth: true
                    columns: 2
                    rowSpacing: Kirigami.Units.smallSpacing
                    columnSpacing: Kirigami.Units.largeSpacing

                    QtControls.CheckBox {
                        id: showDiskMonitor
                        text: i18n("Enabled?")
                    }
                }
            }
        }

        // Click action
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
                    inputMethodHints: Qt.ImhNoPredictiveText
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

                PlasmaComponents.ScrollView {
                    anchors.fill: parent
                    anchors.margins: 10
                    anchors.rightMargin: 5

                    ListView {
                        id: appsList

                        model: appsModel
                        clip: true
                        interactive: true

                        highlight: PlasmaExtras.Highlight {
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
                                appsList.currentIndex = index;
                                cfg_actionService = serviceName;
                            }
                        }

                        Component.onCompleted: updateCurrentIndex()

                        function updateCurrentIndex() {
                            for (var i = 0; i < model.count; i++) {
                                if (model.get(i).menuId === cfg_actionService + ".desktop") {
                                    currentIndex = i;
                                    return;
                                }
                            }
                            currentIndex = -1;
                        }
                    }
                }
            }
        }
    }
}
