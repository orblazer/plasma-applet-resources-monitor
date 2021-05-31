import QtQuick 2.2
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.0

RowLayout {
    id: colorSelector

    // Aliases
    property alias value: colorPicker.currentColor
    property alias checked: customized.checked

    // Properties
    property string label
    property string dialogTitle
    property color defaultColor

    // Components
    ColorDialog {
        id: colorPicker
        title: dialogTitle
    }

    CheckBox {
        id: customized

        Accessible.name: ToolTip.text
        ToolTip {
            text: i18n("Check for use customized color")
        }
    }
    Button {
        onClicked: colorPicker.open()
        enabled: checked

        implicitWidth: height * 2
        background: Rectangle {
            color: checked ? colorPicker.currentColor : defaultColor
            radius: 2
        }
    }
}
