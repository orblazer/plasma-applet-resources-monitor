import QtQuick 2.2
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.0

import "./"

RowLayout {
    id: customizableSize

    // Aliases
    property alias value: spinBox.value
    property alias checked: customized.checked

    property alias from: spinBox.from
    property alias to: spinBox.to
    property alias stepSize: spinBox.stepSize

    // Properties
    property string label
    property string dialogTitle

    // Components
    CheckBox {
        id: customized

        Accessible.name: ToolTip.text
        ToolTip {
            text: i18n("Check for use customized graph width")
        }
    }
    SpinBox {
        id: spinBox

        enabled: customized.checked
        suffix: i18nc('Pixels', 'px')
        Layout.fillWidth: true
    }
}
