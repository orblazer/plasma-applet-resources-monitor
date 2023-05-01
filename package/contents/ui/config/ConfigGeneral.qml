import QtQuick 2.2
import QtQuick.Controls 2.12 as QtControls
import QtQuick.Layouts 1.1 as QtLayouts
import org.kde.kirigami 2.6 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PC2
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import "../components" as RMComponents
import "../controls" as RMControls

PlasmaExtras.Representation {
    id: page
    anchors.fill: parent

    signal configurationChanged

    property alias cfg_updateInterval: updateInterval.valueReal
    property string cfg_cpuUnit: plasmoid.configuration.cpuUnit
    property string cfg_memoryUnit: plasmoid.configuration.memoryUnit
    property string cfg_networkUnit: plasmoid.configuration.networkUnit
    property string cfg_actionService: plasmoid.configuration.actionService

    property bool cfg_showCpuMonitor: plasmoid.configuration.showCpuMonitor.checked
    property alias cfg_showClock: showCpuClock.checked
    property alias cfg_showCpuTemperature: showCpuTemperature.checked
    property bool cfg_showRamMonitor: plasmoid.configuration.showRamMonitor.checked
    property alias cfg_memorySwapGraph: memorySwapGraph.checked
    property bool cfg_showNetMonitor: plasmoid.configuration.showNetMonitor.checked
    property alias cfg_showGpuMonitor: showGpuMonitor.checked
    property alias cfg_gpuMemoryInPercent: gpuMemoryInPercent.checked
    property alias cfg_gpuMemoryGraph: gpuMemoryGraph.checked
    property alias cfg_showGpuTemperature: showGpuTemperature.checked
    property alias cfg_showDiskMonitor: showDiskMonitor.checked

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
            currentIndex: swipeView.currentIndex

            position: PlasmaComponents.TabBar.Header
            anchors.fill: parent
            implicitHeight: contentHeight

            PlasmaComponents.TabButton {
                Accessible.onPressAction: clicked()
                icon.name: "preferences-system-windows"
                icon.height: PlasmaCore.Units.iconSizes.smallMedium
                text: i18n("General")
                onClicked: {
                    swipeView.currentIndex = 0;
                }
            }
            PlasmaComponents.TabButton {
                Accessible.onPressAction: clicked()
                icon.name: "input-mouse-click-left"
                icon.height: PlasmaCore.Units.iconSizes.smallMedium
                text: i18n("Click action")
                onClicked: {
                    swipeView.currentIndex = 1;
                }
            }
        }
    }

    PlasmaComponents.SwipeView {
        id: swipeView
        anchors.fill: parent

        activeFocusOnTab: false
        clip: true

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

                // Separator
                Rectangle {
                    height: Kirigami.Units.largeSpacing * 2
                    color: "transparent"
                }

                // Charts
                PlasmaComponents.Label {
                    text: i18n("Charts")
                    font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.2
                }

                // CPU
                PlasmaComponents.Label {
                    text: i18n("CPU monitor")
                    font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.05
                }

                QtControls.ComboBox {
                    QtLayouts.Layout.fillWidth: true
                    Kirigami.FormData.label: i18n("Visibility:")
                    textRole: "label"
                    model: [{
                            "label": i18n("Disabled"),
                            "value": "none"
                        }, {
                            "label": i18n("With Total usage"),
                            "value": "usage"
                        }, {
                            "label": i18n("With System usage"),
                            "value": "system"
                        }, {
                            "label": i18n("With User usage"),
                            "value": "user"
                        }]

                    onCurrentIndexChanged: {
                        var current = model[currentIndex];
                        if (current) {
                            if (current.value === "none") {
                                cfg_showCpuMonitor = false;
                                page.configurationChanged();
                            } else {
                                cfg_showCpuMonitor = true;
                                cfg_cpuUnit = current.value;
                                page.configurationChanged();
                            }
                        }
                    }

                    Component.onCompleted: {
                        if (!plasmoid.configuration.showCpuMonitor) {
                            currentIndex = 0;
                        } else {
                            for (var i = 0; i < model.length; i++) {
                                if (model[i]["value"] === plasmoid.configuration.cpuUnit) {
                                    currentIndex = i;
                                    return;
                                }
                            }
                        }
                    }
                }

                QtLayouts.GridLayout {
                    QtLayouts.Layout.fillWidth: true
                    columns: 2
                    rowSpacing: Kirigami.Units.smallSpacing
                    columnSpacing: Kirigami.Units.largeSpacing

                    QtControls.CheckBox {
                        id: showCpuClock
                        text: i18n("Show clock")
                        enabled: cfg_showCpuMonitor
                    }
                    QtControls.CheckBox {
                        id: showCpuTemperature
                        text: i18n("Show temperature")
                        enabled: cfg_showCpuMonitor
                    }
                    Rectangle {
                        height: Kirigami.Units.largeSpacing
                        color: "transparent"
                    }
                }

                // Memory
                Rectangle {
                    height: Kirigami.Units.largeSpacing * 2
                    color: "transparent"
                }
                PlasmaComponents.Label {
                    text: i18n("Memory monitor")
                    font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.05
                }

                QtControls.ComboBox {
                    QtLayouts.Layout.fillWidth: true
                    Kirigami.FormData.label: i18n("Visibility:")
                    textRole: "label"
                    model: [{
                            "label": i18n("Disabled"),
                            "value": "none"
                        }, {
                            "label": i18n("With Physical memory (KiB)"),
                            "value": "physical"
                        }, {
                            "label": i18n("With Physical memory (in %)"),
                            "value": "physical-percent"
                        }, {
                            "label": i18n("With Application memory (KiB)"),
                            "value": "application"
                        }, {
                            "label": i18n("With Application memory (in %)"),
                            "value": "application-percent"
                        }]

                    onCurrentIndexChanged: {
                        var current = model[currentIndex];
                        if (current) {
                            if (current.value === "none") {
                                cfg_showRamMonitor = false;
                                page.configurationChanged();
                            } else {
                                cfg_showRamMonitor = true;
                                cfg_memoryUnit = current.value;
                                page.configurationChanged();
                            }
                        }
                    }

                    Component.onCompleted: {
                        if (!plasmoid.configuration.showRamMonitor) {
                            currentIndex = 0;
                        } else {
                            for (var i = 0; i < model.length; i++) {
                                if (model[i]["value"] === plasmoid.configuration.memoryUnit) {
                                    currentIndex = i;
                                    return;
                                }
                            }
                        }
                    }
                }

                QtLayouts.GridLayout {
                    QtLayouts.Layout.fillWidth: true
                    columns: 2
                    rowSpacing: Kirigami.Units.smallSpacing
                    columnSpacing: Kirigami.Units.largeSpacing

                    QtControls.CheckBox {
                        id: memorySwapGraph
                        text: i18n("Display swap graph")
                        enabled: cfg_showRamMonitor
                    }
                }

                // Network
                Rectangle {
                    height: Kirigami.Units.largeSpacing * 2
                    color: "transparent"
                }
                PlasmaComponents.Label {
                    text: i18n("Network monitor")
                    font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.05
                }

                QtControls.ComboBox {
                    QtLayouts.Layout.fillWidth: true
                    Kirigami.FormData.label: i18n("Visibility:")
                    textRole: "label"
                    model: [{
                            "label": i18n("Disabled"),
                            "value": "none"
                        }, {
                            "label": i18n("In kibibyte (KiB/s)"),
                            "value": "kibibyte"
                        }, {
                            "label": i18n("In kilobit (Kbps)"),
                            "value": "kilobit"
                        }, {
                            "label": i18n("In kilobyte (KBps)"),
                            "value": "kilobyte"
                        }]

                    onCurrentIndexChanged: {
                        var current = model[currentIndex];
                        if (current) {
                            if (current.value === "none") {
                                cfg_showNetMonitor = false;
                                page.configurationChanged();
                            } else {
                                cfg_showNetMonitor = true;
                                cfg_networkUnit = current.value;
                                page.configurationChanged();
                            }
                        }
                    }

                    Component.onCompleted: {
                        if (!plasmoid.configuration.showNetMonitor) {
                            currentIndex = 0;
                        } else {
                            for (var i = 0; i < model.length; i++) {
                                if (model[i]["value"] === plasmoid.configuration.networkUnit) {
                                    currentIndex = i;
                                    return;
                                }
                            }
                        }
                    }
                }

                // GPU
                Rectangle {
                    height: Kirigami.Units.largeSpacing * 2
                    color: "transparent"
                }
                PlasmaComponents.Label {
                    text: i18n("GPU monitor")
                    font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.05
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
                        text: i18n("Display memory graph")
                        enabled: showGpuMonitor.checked
                    }
                    QtControls.CheckBox {
                        id: gpuMemoryInPercent
                        text: i18n("Values in percentage")
                        enabled: gpuMemoryGraph.checked
                    }
                    QtControls.CheckBox {
                        id: showGpuTemperature
                        text: i18n("Show temperature")
                        enabled: showGpuMonitor.checked
                    }
                }

                // Disk I/O
                Rectangle {
                    height: Kirigami.Units.largeSpacing * 2
                    color: "transparent"
                }
                PlasmaComponents.Label {
                    text: i18n("Disk I/O monitor")
                    font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.05
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

                        highlight: PC2.Highlight {
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
                                var oldValue = cfg_actionService;
                                cfg_actionService = serviceName;
                                if (cfg_actionService !== oldValue) {
                                    page.configurationChanged();
                                }
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
