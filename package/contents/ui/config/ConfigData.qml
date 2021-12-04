import QtQuick 2.2
import QtQuick.Controls 2.12 as QtControls
import QtQuick.Layouts 1.1 as QtLayouts
import org.kde.kirigami 2.6 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "../components" as RMComponents
import "../controls" as RMControls
import "../components/functions.js" as Functions

QtLayouts.ColumnLayout {
    id: dataPage

    signal configurationChanged

    property alias cfg_memoryUseAllocated: memoryUseAllocated.checked
    property alias cfg_memorySwapGraph: memorySwapGraph.checked

    property var networkUnit: Functions.getNetworkUnit(plasmoid.configuration.networkUnit)
    property var networkSpeedOptions: Functions.getSpeedOptions(plasmoid.configuration.networkUnit)
    property double cfg_downloadMaxKiBps: 0.0
    property double cfg_uploadMaxKiBps: 0.0

    // Detect network interfaces
    RMComponents.SensorDetector {
        id: sensorDetector
        property var networkInterfaces: []
        property var networkRegex: /^network\/interfaces\/(?!lo|bridge|usbus|bond)(.*)\/transmitter\/data$/

        onModelChanged: {
            var newList = []
            var i, sensor, match
            for (i = 0; i < model.count; i++) {
                sensor = model.get(i)
                if ((match = sensor.name.match(networkRegex)) != null && newList.indexOf(match[1]) === -1) {
                    newList.push(match[1])
                }
            }
            networkInterfaces = newList
            networkInterfacesChanged()
        }
    }

    // Tab bar
    PlasmaComponents.TabBar {
        id: bar

        PlasmaComponents.TabButton {
            tab: memoryPage
            iconSource: "memory-symbolic"
            text: i18n("Memory")
        }
        PlasmaComponents.TabButton {
            tab: networkPage
            iconSource: "preferences-system-network"
            text: i18n("Network")
        }
    }

    // Views
    PlasmaComponents.TabGroup {
        QtLayouts.Layout.fillWidth: true
        QtLayouts.Layout.fillHeight: true

        // Memory
        Kirigami.FormLayout {
            id: memoryPage

            PlasmaComponents.CheckBox {
                id: memoryUseAllocated
                text: i18n("Use allocated memory instead of application")
            }

            PlasmaComponents.CheckBox {
                id: memorySwapGraph
                text: i18n("Display memory swap graph")
            }
        }

        // Network
        Kirigami.FormLayout {
            id: networkPage
            wideMode: true

            // Network interfaces
            QtLayouts.GridLayout {
                Kirigami.FormData.label: i18n("Network interfaces:")
                QtLayouts.Layout.fillWidth: true
                columns: 2
                rowSpacing: Kirigami.Units.smallSpacing
                columnSpacing: Kirigami.Units.largeSpacing

                Repeater {
                    model: sensorDetector.networkInterfaces
                    QtControls.CheckBox {
                        readonly property string interfaceName: modelData
                        readonly property bool ignoredByDefault: {
                            return /^(docker|tun|tap)(\d+)/.test(interfaceName) // Ignore docker and tun/tap networks
                        }

                        text: interfaceName
                        checked: plasmoid.configuration.ignoredNetworkInterfaces.indexOf(interfaceName) == -1 && !ignoredByDefault
                        enabled: !ignoredByDefault

                        onClicked: {
                            var ignoredNetworkInterfaces = plasmoid.configuration.ignoredNetworkInterfaces.slice(0) // copy()
                            if (checked) {
                                // Checking, and thus removing from the ignoredNetworkInterfaces
                                var i = ignoredNetworkInterfaces.indexOf(interfaceName)
                                ignoredNetworkInterfaces.splice(i, 1)
                                plasmoid.configuration.ignoredNetworkInterfaces = ignoredNetworkInterfaces
                            } else {
                                // Unchecking, and thus adding to the ignoredNetworkInterfaces
                                ignoredNetworkInterfaces.push(interfaceName)
                                plasmoid.configuration.ignoredNetworkInterfaces = ignoredNetworkInterfaces
                            }
                            // To modify a StringList we need to manually trigger configurationChanged.
                            dataPage.configurationChanged()
                        }
                    }
                }
            }

            // Separator
            Rectangle {
                height: Kirigami.Units.largeSpacing * 2
                color: "transparent"
            }

            PlasmaComponents.Label {
                text: i18n("Maximum transfer speed")
                font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.2
            }

            // Separator
            Rectangle {
                height: Kirigami.Units.largeSpacing
                color: "transparent"
            }

            // Receiving speed
            QtControls.ComboBox {
                id: downloadMaxSpeed
                Kirigami.FormData.label: i18n("Receiving:")
                textRole: "label"
                model: networkSpeedOptions

                onCurrentIndexChanged: {
                    var current = model[currentIndex]
                    if (current && current.value !== -1) {
                        customDownloadMaxSpeed.valueReal = current.rawValue
                    }
                }

                Component.onCompleted: {
                    for (var i = 0; i < model.length; i++) {
                        if (model[i]["value"] === plasmoid.configuration.downloadMaxKiBps) {
                            downloadMaxSpeed.currentIndex = i;
                            return
                        }
                    }

                    downloadMaxSpeed.currentIndex = 0 // Custom
                }
            }
            RMControls.SpinBox {
                id: customDownloadMaxSpeed
                Kirigami.FormData.label: i18n("Custom value:")
                QtLayouts.Layout.fillWidth: true
                decimals: 3
                stepSize: 1
                minimumValue: 0.001
                visible: downloadMaxSpeed.currentIndex === 0

                textFromValue: function(value) {
                    return valueToText(value) + " M" + networkUnit.suffix
                }

                onValueChanged: {
                    var value = valueReal / networkUnit.multiplier

                    cfg_downloadMaxKiBps = Math.round(value * 1000)
                    dataPage.configurationChanged()
                }
                Component.onCompleted: {
                    var value = parseFloat(plasmoid.configuration.downloadMaxKiBps) * networkUnit.multiplier
                    valueReal = value / 1000
                }
            }

            // Separator
            Rectangle {
                height: Kirigami.Units.largeSpacing
                color: "transparent"
            }

            // Sending speed
            QtControls.ComboBox {
                id: uploadMaxSpeed
                Kirigami.FormData.label: i18n("Sending:")
                textRole: "label"
                model: networkSpeedOptions

                onCurrentIndexChanged: {
                    var current = model[currentIndex]
                    if (current && current.value !== -1) {
                        customUploadMaxSpeed.valueReal = current.rawValue
                    }
                }

                Component.onCompleted: {
                    for (var i = 0; i < model.length; i++) {
                        if (model[i]["value"] === plasmoid.configuration.uploadMaxKiBps) {
                            uploadMaxSpeed.currentIndex = i;
                            return
                        }
                    }

                    uploadMaxSpeed.currentIndex = 0 // Custom
                }
            }
            RMControls.SpinBox {
                id: customUploadMaxSpeed
                Kirigami.FormData.label: i18n("Custom value:")
                QtLayouts.Layout.fillWidth: true
                decimals: 3
                stepSize: 1
                minimumValue: 0.001
                visible: uploadMaxSpeed.currentIndex === 0

                textFromValue: function(value) {
                    return valueToText(value) + " M" + networkUnit.suffix
                }

                onValueChanged: {
                    var value = valueReal / networkUnit.multiplier

                    cfg_uploadMaxKiBps = Math.round(value * 1000)
                    dataPage.configurationChanged()
                }
                Component.onCompleted: {
                    var value = parseFloat(plasmoid.configuration.uploadMaxKiBps) * networkUnit.multiplier
                    valueReal = value / 1000
                }
            }
        }
    }
}
