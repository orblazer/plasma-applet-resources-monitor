import QtQuick 2.2
import QtQuick.Controls 2.15 as QtControls
import QtQuick.Layouts 1.1 as QtLayouts
import org.kde.kirigami 2.13 as Kirigami

import "../components"

Kirigami.FormLayout {
    property alias cfg_memoryUseAllocated: memoryUseAllocated.checked
    property alias cfg_networkSensorInterface: networkSensorInterface.text
    property alias cfg_downloadMaxKBs: downloadMaxKBs.value
    property alias cfg_uploadMaxKBs: uploadMaxKBs.value


    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n('Memory')
    }

    QtControls.CheckBox {
        id: memoryUseAllocated
        text: i18n('Use allocated memory instead of application')
    }

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n('Network')
    }

    QtControls.TextField {
        id: networkSensorInterface
        Kirigami.FormData.label: i18n('Network interface:')
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
        to: 100000
        suffix: i18nc('Abbreviation for KB/s', ' KB/s')
    }
    SpinBox {
        id: uploadMaxKBs
        Kirigami.FormData.label: i18n('Max upload speed:')
        QtLayouts.Layout.fillWidth: true
        stepSize: 10
        from: 10
        to: 100000
        suffix: i18nc('Abbreviation for KB/s', ' KB/s')
    }
}
