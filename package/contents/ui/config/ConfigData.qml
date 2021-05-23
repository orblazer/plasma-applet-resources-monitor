import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {

    property alias cfg_networkSensorInterface: networkSensorInterface.text
    property alias cfg_downloadMaxKBs: downloadMaxKBs.value
    property alias cfg_uploadMaxKBs: uploadMaxKBs.value

    GridLayout {
        Layout.fillWidth: true
        columns: 2

        Label {
            text: i18n('Network sensor interface')
            Layout.alignment: Qt.AlignRight
        }
        TextField {
            id: networkSensorInterface
            placeholderText: 'enp3s0'
            Layout.preferredWidth: 500
            onTextChanged: cfg_networkSensorInterface = text
        }

        Label {
            text: i18n('Max download speed:')
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: downloadMaxKBs
            decimals: 0
            stepSize: 10
            minimumValue: 10
            maximumValue: 100000
            value: cfg_downloadMaxKBs
            suffix: i18nc('Abbreviation for KB/s', ' KB/s')
        }

        Label {
            text: i18n('Max upload speed:')
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: uploadMaxKBs
            decimals: 0
            stepSize: 10
            minimumValue: 10
            maximumValue: 100000
            value: cfg_uploadMaxKBs
            suffix: i18nc('Abbreviation for KB/s', ' KB/s')
        }
    }

}
