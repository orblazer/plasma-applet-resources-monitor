import QtQuick 2.2
import QtQuick.Controls 2.12 as QtControls
import QtQuick.Layouts 1.1 as QtLayouts
import org.kde.kirigami 2.6 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "../controls" as RMControls

QtLayouts.ColumnLayout {
    spacing: Kirigami.Units.largeSpacing

    property alias cfg_updateInterval: updateInterval.valueReal

    property alias cfg_showCpuMonitor: showCpuMonitor.checked
    property alias cfg_showClock: showClock.checked
    property alias cfg_showRamMonitor: showRamMonitor.checked
    property alias cfg_memoryInPercent: memoryInPercent.checked
    property alias cfg_showNetMonitor: showNetMonitor.checked


    Kirigami.FormLayout {
        wideMode: true

        RMControls.SpinBox {
            id: updateInterval
            Kirigami.FormData.label: i18n('Update interval:')
            QtLayouts.Layout.fillWidth: true

            decimals: 1
            minimumValue: 0.1
            maximumValue: 3600.0
            stepSize: Math.round(0.1 * factor)

            textFromValue: function(value) {
                return i18np('%1 second', '%1 seconds', valueToText(value))
            }
        }
    }

    // Charts
    PlasmaComponents.Label {
        text: i18n('Charts')
        font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.2
    }

    QtLayouts.GridLayout {
        QtLayouts.Layout.fillWidth: true
        columns: 2
        rowSpacing: Kirigami.Units.smallSpacing
        columnSpacing: Kirigami.Units.largeSpacing

        // CPU
        QtControls.CheckBox {
            id: showCpuMonitor
            text: i18n('Show CPU monitor')
        }
        QtControls.CheckBox {
            id: showClock
            text: i18n('Show clock')
            enabled: showCpuMonitor.checked
        }

        // Memory
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

    Item {
        QtLayouts.Layout.fillWidth: true
        QtLayouts.Layout.fillHeight: true
    }
}
