import QtQuick
import QtQuick.Controls as QtControls
import QtQuick.Layouts as QtLayouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import "../components" as RMComponents
import "../controls" as RMControls
import "../components/functions.mjs" as Functions

KCM.AbstractKCM {
    // Make pages fill the whole view by default
    Kirigami.ColumnView.fillWidth: true

    // CPU
    property alias cfg_cpuECoresCount: cpuECoresCount.value

    // Network
    readonly property var networkDialect: Functions.getNetworkDialectInfo(Plasmoid.configuration.networkUnit, i18nc)
    property var cfg_ignoredNetworkInterfaces: []
    property alias cfg_networkReceivingTotal: networkReceiving.realValue
    property alias cfg_networkSendingTotal: networkSending.realValue

    // Disks I/O
    property alias cfg_diskReadTotal: diskRead.realValue
    property alias cfg_diskWriteTotal: diskWrite.realValue

    // GPU
    property string cfg_gpuIndex

    // Thresholds
    property alias cfg_thresholdWarningCpuTemp: thresholdWarningCpuTemp.realValue
    property alias cfg_thresholdCriticalCpuTemp: thresholdCriticalCpuTemp.realValue
    property alias cfg_thresholdWarningMemory: thresholdWarningMemory.value
    property alias cfg_thresholdCriticalMemory: thresholdCriticalMemory.value
    property alias cfg_thresholdWarningGpuTemp: thresholdWarningGpuTemp.realValue
    property alias cfg_thresholdCriticalGpuTemp: thresholdCriticalGpuTemp.realValue

    readonly property var networkSpeedOptions: [
        {
            "label": i18n("Custom"),
            "value": -1
        },
        {
            "label": i18n("Automatic"),
            "value": 0.0
        },
        {
            "label": "100 " + networkDialect.kiloChar + networkDialect.suffix,
            "value": 100.0
        },
        {
            "label": "1 M" + networkDialect.suffix,
            "value": 1000.0
        },
        {
            "label": "10 M" + networkDialect.suffix,
            "value": 10000.0
        },
        {
            "label": "100 M" + networkDialect.suffix,
            "value": 100000.0
        },
        {
            "label": "1 G" + networkDialect.suffix,
            "value": 1000000.0
        },
        {
            "label": "2.5 G" + networkDialect.suffix,
            "value": 2500000.0
        },
        {
            "label": "5 G" + networkDialect.suffix,
            "value": 5000000.0
        },
        {
            "label": "10 G" + networkDialect.suffix,
            "value": 10000000.0
        }
    ]
    readonly property var diskSpeedOptions: [
        {
            "label": i18n("Custom"),
            "value": -1
        },
        {
            "label": i18n("Automatic"),
            "value": 0.0
        },
        {
            "label": "10 MiB/s",
            "value": 10000.0
        },
        {
            "label": "100 MiB/s",
            "value": 100000.0
        },
        {
            "label": "200 MiB/s",
            "value": 200000.0
        },
        {
            "label": "500 MiB/s",
            "value": 500000.0
        },
        {
            "label": "1 GiB/s",
            "value": 1000000.0
        },
        {
            "label": "2 GiB/s",
            "value": 2000000.0
        },
        {
            "label": "5 GiB/s",
            "value": 5000000.0
        },
        {
            "label": "10 GiB/s",
            "value": 10000000.0
        }
    ]

    // Detect network interfaces
    RMComponents.NetworkInterfaceDetector {
        id: networkInterfaces
    }
    // Detect GPU cards
    RMComponents.GpuDetector {
        id: gpuCards

        onReady: gpuCardSelector.select()
    }

    // Tab bar
    header: PlasmaComponents.TabBar {
        id: bar

        PlasmaComponents.TabButton {
            icon.name: "settings"
            icon.height: Kirigami.Units.iconSizes.smallMedium
            text: i18nc("Config header", "General")
        }
        PlasmaComponents.TabButton {
            icon.name: "dialog-warning"
            icon.height: Kirigami.Units.iconSizes.smallMedium
            text: i18nc("Config header", "Thresholds")
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

                // CPU
                Kirigami.Separator {
                    Kirigami.FormData.label: i18nc("Chart name", "CPU")
                    Kirigami.FormData.isSection: true
                    QtLayouts.Layout.minimumWidth: 200 // Prevent too small inputs
                }

                // Define Number of E-Cores, it's used for separating Intel
                // E-cores and P-Cores when calculating CPU frequency,
                // because they have different frequencies.
                RMControls.SpinBox {
                    id: cpuECoresCount
                    Kirigami.FormData.label: i18n("E-cores")
                    QtLayouts.Layout.fillWidth: true
                }
                Kirigami.InlineMessage {
                    visible: true
                    QtLayouts.Layout.fillWidth: true
                    text: i18n("<b>Intel 12+ gen Only</b><br>Define number of E-Cores your CPU have. This is for separating from P-Cores in cpu frequency.")
                }

                // Network
                Kirigami.Separator {
                    Kirigami.FormData.label: i18nc("Chart name", "Network")
                    Kirigami.FormData.isSection: true
                }

                // Interfaces
                QtLayouts.GridLayout {
                    Kirigami.FormData.label: i18n("Network interfaces:")
                    QtLayouts.Layout.fillWidth: true

                    columns: 2
                    rowSpacing: Kirigami.Units.smallSpacing
                    columnSpacing: Kirigami.Units.largeSpacing

                    Repeater {
                        model: networkInterfaces
                        QtControls.CheckBox {
                            readonly property string interfaceName: model.SensorId.replace('network/', '').replace('/network', '')
                            readonly property bool ignoredByDefault: {
                                return /^(docker|tun|tap)(\d+)/.test(interfaceName); // Ignore docker and tun/tap networks
                            }

                            text: interfaceName
                            checked: cfg_ignoredNetworkInterfaces.indexOf(interfaceName) == -1 && !ignoredByDefault
                            enabled: !ignoredByDefault

                            onClicked: {
                                var ignoredNetworkInterfaces = cfg_ignoredNetworkInterfaces.slice(0); // copy()
                                if (checked) {
                                    // Checking, and thus removing from the ignoredNetworkInterfaces
                                    var i = ignoredNetworkInterfaces.indexOf(interfaceName);
                                    ignoredNetworkInterfaces.splice(i, 1);
                                } else {
                                    // Unchecking, and thus adding to the ignoredNetworkInterfaces
                                    ignoredNetworkInterfaces.push(interfaceName);
                                }
                                cfg_ignoredNetworkInterfaces = ignoredNetworkInterfaces;
                            }
                        }
                    }
                }

                // Transfer speed
                Item {
                    Kirigami.FormData.label: i18n("Maximum transfer speed")
                    Kirigami.FormData.isSection: true
                }

                RMControls.PredefinedSpinBox {
                    id: networkReceiving
                    Kirigami.FormData.label: i18nc("Chart config", "Receiving:")
                    QtLayouts.Layout.fillWidth: true
                    QtLayouts.Layout.minimumWidth: predefinedChoices.currentIndex == 0 ? 300 : 0
                    factor: 1000

                    predefinedChoices {
                        textRole: "label"
                        valueRole: "value"
                        model: networkSpeedOptions
                    }

                    spinBox {
                        decimals: 3
                        stepSize: 1
                        minimumValue: 0.001

                        textFromValue: function (value, locale) {
                            return spinBox.valueToText(value, locale) + " M" + networkDialect.suffix;
                        }
                    }
                }

                RMControls.PredefinedSpinBox {
                    id: networkSending
                    Kirigami.FormData.label: i18nc("Chart config", "Sending:")
                    QtLayouts.Layout.fillWidth: true
                    QtLayouts.Layout.minimumWidth: predefinedChoices.currentIndex == 0 ? 300 : 0
                    factor: 1000

                    predefinedChoices {
                        textRole: "label"
                        valueRole: "value"
                        model: networkSpeedOptions
                    }

                    spinBox {
                        decimals: 3
                        stepSize: 1
                        minimumValue: 0.001

                        textFromValue: function (value, locale) {
                            return spinBox.valueToText(value, locale) + " M" + networkDialect.suffix;
                        }
                    }
                }

                // Disk I/O
                Kirigami.Separator {
                    Kirigami.FormData.label: i18nc("Chart name", "Disks I/O")
                    Kirigami.FormData.isSection: true
                }

                Item {
                    Kirigami.FormData.label: i18n("Maximum transfer speed")
                    Kirigami.FormData.isSection: true
                }

                RMControls.PredefinedSpinBox {
                    id: diskRead
                    Kirigami.FormData.label: i18nc("Chart config", "Read:")
                    QtLayouts.Layout.fillWidth: true
                    QtLayouts.Layout.minimumWidth: predefinedChoices.currentIndex == 0 ? 300 : 0
                    factor: 1000

                    predefinedChoices {
                        textRole: "label"
                        valueRole: "value"
                        model: diskSpeedOptions
                    }

                    spinBox {
                        decimals: 3
                        stepSize: 1
                        minimumValue: 0.001

                        textFromValue: function (value, locale) {
                            return spinBox.valueToText(value, locale) + " M" + networkDialect.suffix;
                        }
                    }
                }

                RMControls.PredefinedSpinBox {
                    id: diskWrite
                    Kirigami.FormData.label: i18nc("Chart config", "Write:")
                    QtLayouts.Layout.fillWidth: true
                    QtLayouts.Layout.minimumWidth: predefinedChoices.currentIndex == 0 ? 300 : 0
                    factor: 1000

                    predefinedChoices {
                        textRole: "label"
                        valueRole: "value"
                        model: diskSpeedOptions
                    }

                    spinBox {
                        decimals: 3
                        stepSize: 1
                        minimumValue: 0.001

                        textFromValue: function (value, locale) {
                            return spinBox.valueToText(value, locale) + " M" + networkDialect.suffix;
                        }
                    }
                }

                // GPU
                Kirigami.Separator {
                    Kirigami.FormData.label: i18nc("Config header", "Graphic card")
                    Kirigami.FormData.isSection: true
                }

                QtControls.ComboBox {
                    id: gpuCardSelector
                    QtLayouts.Layout.fillWidth: true
                    Kirigami.FormData.label: i18n("Graphic card:")

                    currentIndex: -1
                    textRole: "name"
                    valueRole: "index"
                    model: gpuCards.model

                    onActivated: cfg_gpuIndex = currentValue
                    function select() {
                        currentIndex = indexOfValue(cfg_gpuIndex);
                    }
                }
            }

            // Thresholds
            Kirigami.FormLayout {
                id: thresholdsPage
                wideMode: true

                property double kirigamiWidth: preferredWidth * 2 + Kirigami.Units.largeSpacing
                property double preferredWidth: {
                    const minimumWidth = Math.max(80, warningHeader.contentWidth, criticalHeader.contentWidth);
                    return Math.max(minimumWidth,
                    // CPU
                    thresholdWarningCpuTemp.implicitWidth, thresholdCriticalCpuTemp.implicitWidth,
                    // Memory
                    thresholdWarningMemory.implicitWidth, thresholdCriticalMemory.implicitWidth,
                    // Memory
                    thresholdWarningMemory.implicitWidth, thresholdCriticalMemory.implicitWidth,
                    // GPU
                    thresholdWarningGpuTemp.implicitWidth, thresholdCriticalGpuTemp.implicitWidth);
                }

                // Header
                QtLayouts.RowLayout {
                    QtLayouts.Layout.fillWidth: true
                    spacing: Kirigami.Units.largeSpacing

                    PlasmaComponents.Label {
                        id: warningHeader
                        text: i18n("Warning")
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.2
                        QtLayouts.Layout.preferredWidth: thresholdsPage.preferredWidth
                    }

                    PlasmaComponents.Label {
                        id: criticalHeader
                        text: i18n("Critical")
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.2
                    }
                }

                // CPU Temperature
                QtLayouts.RowLayout {
                    Kirigami.FormData.label: i18n("CPU Temperature:")
                    QtLayouts.Layout.preferredWidth: thresholdsPage.kirigamiWidth
                    spacing: Kirigami.Units.largeSpacing

                    RMControls.SpinBox {
                        id: thresholdWarningCpuTemp
                        QtLayouts.Layout.preferredWidth: thresholdsPage.preferredWidth
                        decimals: 1
                        stepSize: 1
                        minimumValue: 0.1
                        maximumValue: 120

                        textFromValue: function (value, locale) {
                            return valueToText(value, locale) + " °C";
                        }
                    }
                    RMControls.SpinBox {
                        id: thresholdCriticalCpuTemp
                        QtLayouts.Layout.preferredWidth: thresholdsPage.preferredWidth
                        decimals: 1
                        stepSize: 1
                        minimumValue: 0.1
                        maximumValue: 120

                        textFromValue: function (value, locale) {
                            return valueToText(value, locale) + " °C";
                        }
                    }
                }

                // Memory usage
                QtLayouts.RowLayout {
                    Kirigami.FormData.label: i18n("Physical Memory Usage:")
                    QtLayouts.Layout.preferredWidth: thresholdsPage.kirigamiWidth
                    spacing: Kirigami.Units.largeSpacing

                    RMControls.SpinBox {
                        id: thresholdWarningMemory
                        QtLayouts.Layout.preferredWidth: thresholdsPage.preferredWidth

                        textFromValue: function (value, locale) {
                            return value + " %";
                        }
                    }
                    RMControls.SpinBox {
                        id: thresholdCriticalMemory
                        QtLayouts.Layout.preferredWidth: thresholdsPage.preferredWidth

                        textFromValue: function (value, locale) {
                            return value + " %";
                        }
                    }
                }

                // GPU Temperature
                QtLayouts.RowLayout {
                    Kirigami.FormData.label: i18n("GPU Temperature:")
                    QtLayouts.Layout.preferredWidth: thresholdsPage.kirigamiWidth
                    spacing: Kirigami.Units.largeSpacing

                    RMControls.SpinBox {
                        id: thresholdWarningGpuTemp
                        QtLayouts.Layout.preferredWidth: thresholdsPage.preferredWidth

                        decimals: 1
                        stepSize: 1
                        minimumValue: 0.1
                        maximumValue: 120

                        textFromValue: function (value, locale) {
                            return valueToText(value, locale) + " °C";
                        }
                    }
                    RMControls.SpinBox {
                        id: thresholdCriticalGpuTemp
                        QtLayouts.Layout.preferredWidth: thresholdsPage.preferredWidth

                        decimals: 1
                        stepSize: 1
                        minimumValue: 0.1
                        maximumValue: 120

                        textFromValue: function (value, locale) {
                            return valueToText(value, locale) + " °C";
                        }
                    }
                }
            }
        }
    }
}
