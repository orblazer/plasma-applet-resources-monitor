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

    readonly property var networkDialect: Functions.getNetworkDialectInfo(plasmoid.configuration.networkUnit)
    property double cfg_networkReceivingTotal: 0.0
    property double cfg_networkSendingTotal: 0.0

    readonly property var networkSpeedOptions: [
        {
            label: i18n("Custom"),
            value: -1,
        }, {
            label: "100 " + networkDialect.kiloChar + networkDialect.suffix,
            value: 100.0,
        }, {
            label: "1 M" + networkDialect.suffix,
            value: 1000.0,
        }, {
            label: "10 M" + networkDialect.suffix,
            value: 10000.0,
        }, {
            label: "100 M" + networkDialect.suffix,
            value: 100000.0,
        }, {
            label: "1 G" + networkDialect.suffix,
            value: 1000000.0,
        }, {
            label: "2.5 G" + networkDialect.suffix,
            value: 2500000.0,
        }, {
            label: "5 G" + networkDialect.suffix,
            value: 5000000.0,
        }, {
            label: "10 G" + networkDialect.suffix,
            value: 10000000.0,
        }
    ]

    // Detect network interfaces
    RMComponents.NetworkInterfaceDetector {
        id: networkInterfaces
    }

    // Tab bar
    PlasmaComponents.TabBar {
        id: bar

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
                    model: networkInterfaces.model
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
                            } else {
                                // Unchecking, and thus adding to the ignoredNetworkInterfaces
                                ignoredNetworkInterfaces.push(interfaceName)
                            }

                            plasmoid.configuration.ignoredNetworkInterfaces = ignoredNetworkInterfaces
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
                id: networkReceivingTotal
                Kirigami.FormData.label: i18n("Receiving:")
                textRole: "label"
                model: networkSpeedOptions

                onCurrentIndexChanged: {
                    var current = model[currentIndex]
                    if (current && current.value !== -1) {
                        customNetworkReceivingTotal.valueReal = current.value / 1000
                    }
                }

                Component.onCompleted: {
                    for (var i = 0; i < model.length; i++) {
                        if (model[i]["value"] === plasmoid.configuration.networkReceivingTotal) {
                            networkReceivingTotal.currentIndex = i;
                            return
                        }
                    }

                    networkReceivingTotal.currentIndex = 0 // Custom
                }
            }
            RMControls.SpinBox {
                id: customNetworkReceivingTotal
                Kirigami.FormData.label: i18n("Custom value:")
                QtLayouts.Layout.fillWidth: true
                decimals: 3
                stepSize: 1
                minimumValue: 0.001
                visible: networkReceivingTotal.currentIndex === 0

                textFromValue: function(value, locale) {
                    return valueToText(value, locale) + " M" + networkDialect.suffix
                }

                onValueChanged: {
                    var newValue = valueReal * 1000
                    if (cfg_networkReceivingTotal !== newValue)  {
                        cfg_networkReceivingTotal = newValue
                        dataPage.configurationChanged()
                    }
                }
                Component.onCompleted: {
                    valueReal = parseFloat(plasmoid.configuration.networkReceivingTotal) / 1000
                }
            }

            // Separator
            Rectangle {
                height: Kirigami.Units.largeSpacing
                color: "transparent"
            }

            // Sending speed
            QtControls.ComboBox {
                id: networkSendingTotal
                Kirigami.FormData.label: i18n("Sending:")
                textRole: "label"
                model: networkSpeedOptions

                onCurrentIndexChanged: {
                    var current = model[currentIndex]
                    if (current && current.value !== -1) {
                        customNetworkSendingTotal.valueReal = current.value / 1000
                    }
                }

                Component.onCompleted: {
                    for (var i = 0; i < model.length; i++) {
                        if (model[i]["value"] === plasmoid.configuration.networkSendingTotal) {
                            networkSendingTotal.currentIndex = i;
                            return
                        }
                    }

                    networkSendingTotal.currentIndex = 0 // Custom
                }
            }
            RMControls.SpinBox {
                id: customNetworkSendingTotal
                Kirigami.FormData.label: i18n("Custom value:")
                QtLayouts.Layout.fillWidth: true
                decimals: 3
                stepSize: 1
                minimumValue: 0.001
                visible: networkSendingTotal.currentIndex === 0

                textFromValue: function(value, locale) {
                    return valueToText(value, locale) + " M" + networkDialect.suffix
                }

                 onValueChanged: {
                    var newValue = valueReal * 1000
                    if (cfg_networkSendingTotal !== newValue)  {
                        cfg_networkSendingTotal = newValue
                        dataPage.configurationChanged()
                    }
                }
                Component.onCompleted: {
                    valueReal = parseFloat(plasmoid.configuration.networkSendingTotal) / 1000
                }
            }
        }
    }
}
