import QtQuick 2.2
import QtQuick.Dialogs 1.0 as QtDialog
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.6 as Kirigami

PlasmaComponents.Button {
    id: colorSelector

    // Aliases
    property alias value: colorPicker.currentColor

    // Properties
    property string label
    property string dialogTitle
    property color defaultColor
    property bool customized

    // Customized checkbox
    enabled: Kirigami.FormData.checked
    Kirigami.FormData.checkable: true
    Kirigami.FormData.checked: customized

    onEnabledChanged: customized = enabled
    onClicked: colorPicker.open()

    // Size
    topPadding: 12
    bottomPadding: topPadding
    leftPadding: topPadding * 2
    rightPadding: leftPadding

    // Components
    QtDialog.ColorDialog {
        id: colorPicker
        title: dialogTitle
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressed: mouse.accepted = false
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }

    background: Rectangle {
        color: customized ? colorPicker.currentColor : defaultColor
        opacity: colorPicker.enabled ? 1 : 0.75
        radius: 2
    }
}
