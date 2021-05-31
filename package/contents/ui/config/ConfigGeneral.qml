import QtQuick 2.2
import QtQuick.Controls 2.15 as QtControls
import QtQuick.Layouts 1.1 as QtLayouts
import org.kde.kirigami 2.13 as Kirigami

import "../components"

Kirigami.FormLayout {
    property alias cfg_updateInterval: updateIntervalSpinBox.realValue

    property alias cfg_showCpuMonitor: showCpuMonitor.checked
    property alias cfg_showClock: showClock.checked
    property alias cfg_showRamMonitor: showRamMonitor.checked
    property alias cfg_memoryInPercent: memoryInPercent.checked
    property alias cfg_showNetMonitor: showNetMonitor.checked

    DoubleSpinBox {
        id: updateIntervalSpinBox
        Kirigami.FormData.label: i18n('Update interval:')
        decimals: 1
        realStepSize: 0.1
        realFrom: 0.1
        suffix: i18nc('Abbreviation for seconds', 's')
    }

    // Charts

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n('Charts')
    }

    QtLayouts.GridLayout {
        QtLayouts.Layout.fillWidth: true
        columns: 2

        QtControls.CheckBox {
            id: showCpuMonitor
            text: i18n('Show CPU monitor')
        }
        QtControls.CheckBox {
            id: showClock
            text: i18n('Show clock')
            enabled: showCpuMonitor.checked
        }

        QtControls.CheckBox {
            id: showRamMonitor
            text: i18n('Show RAM monitor')
        }
        QtControls.CheckBox {
            id: memoryInPercent
            text: i18n('Memory in percentage')
            enabled: showRamMonitor.checked
        }

        QtControls.CheckBox {
            id: showNetMonitor
            text: i18n('Show network monitor')
        }
    }
}
