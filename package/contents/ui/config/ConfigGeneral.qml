import QtQuick
import QtQuick.Controls as QtControls
import QtQuick.Layouts as QtLayouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import "../components" as RMComponents
import "../controls" as RMControls

KCM.AbstractKCM {
    // Make pages fill the whole view by default
    Kirigami.ColumnView.fillWidth: true

    // Charts
    property alias cfg_updateInterval: updateInterval.realValue
    // property int cfg_updateInterval
    // > CPU
    property string cfg_cpuUnit
    property bool showCpuMonitor: cfg_cpuUnit !== "none"
    property string cfg_cpuClockType
    property string cfg_cpuClockAgregator
    property alias cfg_showCpuTemperature: showCpuTemperature.checked
    // property bool cfg_showCpuTemperature
    // > Memory
    property string cfg_memoryUnit
    property string cfg_memorySecondUnit
    // > Network
    property string cfg_networkUnit
    // > GPU
    property bool cfg_showGpuMonitor
    property string cfg_gpuMemoryUnit
    property alias cfg_showGpuTemperature: showGpuTemperature.checked
    // property bool cfg_showGpuTemperature
    // > Disks I/O
    property bool cfg_showDiskMonitor

    // Click action
    property alias cfg_clickActionCommand: clickActionCommand.text

    // Tab bar
    header: PlasmaComponents.TabBar {
        id: bar

        PlasmaComponents.TabButton {
            icon.name: "settings"
            icon.height: Kirigami.Units.iconSizes.smallMedium
            text: i18nc("Config header", "General")
        }
        PlasmaComponents.TabButton {
            icon.name: "input-mouse-symbolic"
            icon.height: Kirigami.Units.iconSizes.smallMedium
            text: i18nc("Config header", "Click action")
        }
    }

    Kirigami.ScrollablePage {
        anchors.fill: parent

        QtLayouts.StackLayout {
            currentIndex: bar.currentIndex
            QtLayouts.Layout.fillWidth: true

            // General
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

                    onActivated: cfg_cpuUnit = currentValue
                    Component.onCompleted: currentIndex = indexOfValue(cfg_cpuUnit)
                }

                QtControls.ComboBox {
                    QtLayouts.Layout.fillWidth: true
                    Kirigami.FormData.label: i18n("Second Line:")
                    enabled: showCpuMonitor

                    currentIndex: -1
                    textRole: "label"
                    valueRole: "value"
                    model: [
                        {
                            "label": i18n("Disabled"),
                            "value": "none"
                        },
                        {
                            "label": i18n("Classic/P-cores clock frequency"),
                            "value": "classic"
                        },
                        {
                            "label": i18n("E-cores clock frequency"),
                            "value": "ecores"
                        }
                    ]

                    onActivated: cfg_cpuClockType = currentValue
                    Component.onCompleted: currentIndex = indexOfValue(cfg_cpuClockType)
                }

                QtControls.ComboBox {
                    QtLayouts.Layout.fillWidth: true
                    Kirigami.FormData.label: i18n("Clock aggregator:")
                    enabled: showCpuMonitor

                    currentIndex: -1
                    textRole: "label"
                    valueRole: "value"
                    model: [
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

                    onActivated: cfg_cpuClockAgregator = currentValue
                    Component.onCompleted: currentIndex = indexOfValue(cfg_cpuClockAgregator)
                }

                QtControls.CheckBox {
                    id: showCpuTemperature
                    text: i18n("Show temperature")
                    enabled: showCpuMonitor
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

                    onActivated: cfg_memoryUnit = currentValue
                    Component.onCompleted: currentIndex = indexOfValue(cfg_memoryUnit)
                }

                QtControls.ComboBox {
                    QtLayouts.Layout.fillWidth: true
                    Kirigami.FormData.label: i18n("Second line:")
                    enabled: cfg_memoryUnit !== "none"

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
                            "value": "memory-percent"
                        }
                    ]

                    onActivated: cfg_memorySecondUnit = currentValue
                    Component.onCompleted: currentIndex = indexOfValue(cfg_memorySecondUnit)
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

                    onActivated: cfg_networkUnit = currentValue
                    Component.onCompleted: currentIndex = indexOfValue(cfg_networkUnit)
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

                QtControls.ComboBox {
                    QtLayouts.Layout.fillWidth: true
                    Kirigami.FormData.label: i18n("Visibility:")

                    currentIndex: -1
                    textRole: "label"
                    valueRole: "value"
                    model: [
                        {
                            "label": i18n("Disabled"),
                            "value": false
                        },
                        {
                            "label": i18n("Visible"),
                            "value": true
                        }
                    ]

                    onActivated: cfg_showGpuMonitor = currentValue
                    Component.onCompleted: currentIndex = indexOfValue(cfg_showGpuMonitor)
                }
                QtControls.ComboBox {
                    QtLayouts.Layout.fillWidth: true
                    Kirigami.FormData.label: i18n("Second Line:")
                    enabled: cfg_showGpuMonitor

                    currentIndex: -1
                    textRole: "label"
                    valueRole: "value"
                    model: [
                        {
                            "label": i18n("Disabled"),
                            "value": "none"
                        },
                        {
                            "label": i18n("Memory (in KiB)"),
                            "value": "memory"
                        },
                        {
                            "label": i18n("Memory (in %)"),
                            "value": "memory-percent"
                        }
                    ]

                    onActivated: cfg_gpuMemoryUnit = currentValue
                    Component.onCompleted: currentIndex = indexOfValue(cfg_gpuMemoryUnit)
                }
                QtControls.CheckBox {
                    id: showGpuTemperature
                    text: i18n("Show temperature")
                    enabled: cfg_showGpuMonitor
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

                QtControls.ComboBox {
                    QtLayouts.Layout.fillWidth: true
                    Kirigami.FormData.label: i18n("Visibility:")

                    currentIndex: -1
                    textRole: "label"
                    valueRole: "value"
                    model: [
                        {
                            "label": i18n("Disabled"),
                            "value": false
                        },
                        {
                            "label": i18n("Visible"),
                            "value": true
                        }
                    ]

                    onActivated: cfg_showDiskMonitor = currentValue
                    Component.onCompleted: currentIndex = indexOfValue(cfg_showDiskMonitor)
                }
            }

            // Click action
            Kirigami.FormLayout {
                wideMode: true

                RMControls.PredefinedTextField {
                    id: clickActionCommand
                    Kirigami.FormData.label: i18nc("Chart config", "Action:")
                    QtLayouts.Layout.fillWidth: true
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
                    QtLayouts.Layout.fillWidth: true
                    text: i18n("Command wich be executed, but this have some limitation like \"<code>kioclient exec</code>\" or other similar command not work.")
                }
            }
        }
    }
}
