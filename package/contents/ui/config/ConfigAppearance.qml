import QtQuick 2.2
import QtQuick.Controls 2.15 as QtControls
import QtQuick.Layouts 1.1 as QtLayouts
import org.kde.kirigami 2.13 as Kirigami

import "../components"

Kirigami.FormLayout {
    property alias cfg_verticalLayout: verticalLayout.checked
    property alias cfg_enableShadows: enableShadows.checked
    property alias cfg_fontScale: fontScale.value
    property string cfg_placement: ''
    property string cfg_displayment: ''

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

    QtControls.CheckBox {
        id: enableShadows
        text: i18n('Drop shadows')
    }

    SpinBox {
        id: fontScale
        Kirigami.FormData.label: i18n('Font scale:')
        QtLayouts.Layout.fillWidth: true
        from: 1
        to: 100
        suffix: i18nc('Percent', '%')
    }

    QtControls.ComboBox {
        id: displayment
        Kirigami.FormData.label: i18n('Text displayment:')
        textRole: 'label'
        model: [{
            'label': i18n('Always'),
            'name': 'always'
        }, {
            'label': i18n('On hover'),
            'name': 'hover'
        }, {
            'label': i18n('Hints when hover'),
            'name': 'hover-hints'
        }]
        onCurrentIndexChanged: cfg_displayment = model[currentIndex]['name']

        Component.onCompleted: {
            for (var i = 0; i < model.length; i++) {
                if (model[i]['name'] === plasmoid.configuration.displayment) {
                    displayment.currentIndex = i;
                }
            }
        }
    }

    QtControls.ComboBox {
        id: placement
        Kirigami.FormData.label: i18n('Placement:')
        textRole: 'label'
        model: [{
            'label': i18n('Top/Left'),
            'name': 'top-left'
        }, {
            'label': i18n('Top/Right'),
            'name': 'top-right'
        }, {
            'label': i18n('Bottom/Left'),
            'name': 'bottom-left'
        }, {
            'label': i18n('Bottom/Right'),
            'name': 'bottom-right'
        }]
        onCurrentIndexChanged: cfg_placement = model[currentIndex]['name']

        Component.onCompleted: {
            for (var i = 0; i < model.length; i++) {
                if (model[i]['name'] === plasmoid.configuration.placement) {
                    placement.currentIndex = i;
                }
            }
        }
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
