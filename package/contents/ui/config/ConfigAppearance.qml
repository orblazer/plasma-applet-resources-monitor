import QtQuick 2.2
import QtQuick.Controls 2.15 as QtControls
import QtQuick.Layouts 1.1 as QtLayouts
import org.kde.kirigami 2.13 as Kirigami

import "../components"

Kirigami.FormLayout {
    property alias cfg_verticalLayout: verticalLayout.checked
    property alias cfg_enableHints: enableHints.checked
    property alias cfg_enableShadows: enableShadows.checked
    property alias cfg_fontScale: fontScale.value

    property alias cfg_customWarningColor: warningColor.checked
    property alias cfg_warningColor: warningColor.value
    property alias cfg_customCpuColor: cpuColor.checked
    property alias cfg_cpuColor: cpuColor.value
    property alias cfg_customRamColor: ramColor.checked
    property alias cfg_ramColor: ramColor.value
    property alias cfg_customSwapColor: swapColor.checked
    property alias cfg_swapColor: swapColor.value
    property alias cfg_customNetDownColor: netDownColor.checked
    property alias cfg_netDownColor: netDownColor.value
    property alias cfg_customNetUpColor: netUpColor.checked
    property alias cfg_netUpColor: netUpColor.value

    property color primaryColor: theme.highlightColor
    property color negativeColor: theme.negativeTextColor
    property color neutralColor: theme.neutralTextColor
    property color positiveColor: theme.positiveTextColor


    QtControls.CheckBox {
        id: verticalLayout
        text: i18n('Vertical layout')
    }

    // Text

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n('Text')
    }

    SpinBox {
        id: fontScale
        Kirigami.FormData.label: i18n('Font scale:')
        from: 1
        to: 100
        suffix: i18nc('Percent', '%')
    }

    Item {}

    QtControls.CheckBox {
        id: enableHints
        Kirigami.FormData.label: i18n('Info text:')
        text: i18n('Enable hints')
    }

    QtControls.CheckBox {
        id: enableShadows
        text: i18n('Drop shadows')
    }

    // Colors

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n('Colors')
    }

    ColorSelector {
        id: warningColor
        Kirigami.FormData.label: i18n('Warning color:')

        dialogTitle: i18n('Choose warning color')
        defaultColor: neutralColor
    }

    ColorSelector {
        id: cpuColor
        Kirigami.FormData.label: i18n('CPU color:')

        dialogTitle: i18n('Choose CPU graph color')
        defaultColor: primaryColor
    }

    ColorSelector {
        id: ramColor
        Kirigami.FormData.label: i18n('RAM color:')

        dialogTitle: i18n('Choose RAM graph color')
        defaultColor: primaryColor
    }
    ColorSelector {
        id: swapColor
        Kirigami.FormData.label: i18n('Swap color:')

        dialogTitle: i18n('Choose Swap graph color')
        defaultColor: negativeColor
    }

    ColorSelector {
        id: netDownColor
        Kirigami.FormData.label: i18n('Network Download color:')

        dialogTitle: i18n('Choose Network Download graph color')
        defaultColor: primaryColor
    }
    ColorSelector {
        id: netUpColor
        Kirigami.FormData.label: i18n('Network Upload color:')

        dialogTitle: i18n('Choose Network Upload graph color')
        defaultColor: positiveColor
    }
}
