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
}
