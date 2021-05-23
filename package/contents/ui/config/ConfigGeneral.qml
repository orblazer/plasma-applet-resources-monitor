import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {

    property alias cfg_updateInterval: updateIntervalSpinBox.value

    property alias cfg_showCpuMonitor: showCpuMonitor.checked
    property alias cfg_showClock: showClock.checked
    property alias cfg_showRamMonitor: showRamMonitor.checked
    property alias cfg_memoryInPercent: memoryInPercent.checked
    property alias cfg_showNetMonitor: showNetMonitor.checked

    GridLayout {
        Layout.fillWidth: true
        columns: 2

        Label {
            text: i18n('Update interval:')
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: updateIntervalSpinBox
            decimals: 1
            stepSize: 0.1
            minimumValue: 0.1
            suffix: i18nc('Abbreviation for seconds', 's')
        }

        // Charts

        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }

        CheckBox {
            id: showCpuMonitor
            Layout.columnSpan: 1
            text: i18n('Show CPU monitor')
        }

        CheckBox {
            id: showClock
            Layout.columnSpan: 1
            text: i18n('Show clock')
            enabled: showCpuMonitor.checked
        }

        CheckBox {
            id: showRamMonitor
            Layout.columnSpan: 1
            text: i18n('Show RAM monitor')
        }

        CheckBox {
            id: memoryInPercent
            Layout.columnSpan: 1
            text: i18n('Memory in percentage')
            enabled: showRamMonitor.checked
        }

        CheckBox {
            id: showNetMonitor
            Layout.columnSpan: 1
            text: i18n('Show network monitor')
        }
    }

}
