import QtQuick 2.2
import QtQuick.Controls 2.12 as QtControls
import QtQuick.Layouts 1.1 as QtLayouts

import "./" as RMControls

QtLayouts.RowLayout {
    id: customizableSize

    // Aliases
    property alias value: spinBox.value
    property alias checked: customized.checked

    property alias from: spinBox.from
    property alias to: spinBox.to
    property alias stepSize: spinBox.stepSize

    // Components
    QtControls.CheckBox {
        id: customized

        Accessible.name: QtControls.ToolTip.text
        QtControls.ToolTip {
            text: i18n("Check for use customized graph width")
        }
    }
    RMControls.SpinBox {
        id: spinBox

        enabled: customized.checked
        QtLayouts.Layout.fillWidth: true

        textFromValue: function(value, locale) {
            return valueToText(value, locale) + " px"
        }
    }
}
