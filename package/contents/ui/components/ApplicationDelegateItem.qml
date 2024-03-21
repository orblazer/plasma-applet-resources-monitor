import QtQuick 2.15
import QtQuick.Controls 2.15 as QtControls
import org.kde.kirigami 2.20 as Kirigami

MouseArea {
    id: root
    height: childrenRect.height

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    property string serviceName
    property alias name: content.label
    property string comment
    property alias iconName: content.icon
    property alias selected: content.bold

    Kirigami.BasicListItem {
        id: content
        iconSize: 16

        QtControls.ToolTip.text: (comment !== "" ? comment + "\n\n" : "") + "ID: " + serviceName + ".desktop"
        QtControls.ToolTip.visible: root.containsMouse
    }
}
