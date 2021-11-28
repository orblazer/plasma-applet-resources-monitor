import QtQuick 2.2
import QtQuick.Controls 2.12 as QtControls
import QtQuick.Layouts 1.1 as QtLayouts
import org.kde.kirigami 2.6 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents

import "../components"

QtLayouts.ColumnLayout {
    property alias cfg_memoryUseAllocated: memoryUseAllocated.checked
    property alias cfg_memorySwapGraph: memorySwapGraph.checked
    property alias cfg_networkSensorInterface: networkSensorInterface.text
    property alias cfg_downloadMaxKBs: downloadMaxKBs.value
    property alias cfg_uploadMaxKBs: uploadMaxKBs.value

    PlasmaComponents.TabBar {
        id: bar

        PlasmaComponents.TabButton {
            tab: memoryPage
            iconSource: 'memory-symbolic'
            text: i18n('Memory')
        }
        PlasmaComponents.TabButton {
            tab: networkPage
            iconSource: 'preferences-system-network'
            text: i18n('Network')
        }
    }

    PlasmaComponents.TabGroup {
        QtLayouts.Layout.fillWidth: true
        QtLayouts.Layout.fillHeight: true

        // Memory
        Kirigami.FormLayout {
            id: memoryPage

            QtControls.CheckBox {
                id: memoryUseAllocated
                text: i18n('Use allocated memory instead of application')
            }

            QtControls.CheckBox {
                id: memorySwapGraph
                text: i18n('Display memory swap graph')
            }
        }

        // Network
        Kirigami.FormLayout {
            id: networkPage

            QtControls.TextField {
                id: networkSensorInterface
                Kirigami.FormData.label: i18n('Specific network interface:')
                QtLayouts.Layout.fillWidth: true
                placeholderText: 'enp3s0'
                onTextChanged: cfg_networkSensorInterface = text

                Accessible.name: QtControls.ToolTip.text
                QtControls.ToolTip {
                    text: i18n("The network interface name (could pass \"all\" for every interfaces)")
                }
            }
            SpinBox {
                id: downloadMaxKBs
                Kirigami.FormData.label: i18n('Max download speed:')
                QtLayouts.Layout.fillWidth: true
                stepSize: 10
                from: 10
                to: 10000000
                suffix: i18nc('Abbreviation for KB/s', ' KB/s')
            }
            SpinBox {
                id: uploadMaxKBs
                Kirigami.FormData.label: i18n('Max upload speed:')
                QtLayouts.Layout.fillWidth: true
                stepSize: 10
                from: 10
                to: 10000000
                suffix: i18nc('Abbreviation for KB/s', ' KB/s')
            }
        }
    }
}
