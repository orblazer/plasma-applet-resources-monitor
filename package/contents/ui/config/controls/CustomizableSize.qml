import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

RowLayout {
    spacing: Kirigami.Units.smallSpacing

    property alias checkbox: checkbox
    property alias spinBox: spinBox

    property alias customized: checkbox.checked
    property alias value: spinBox.realValue

    QQC2.ToolTip.visible: ma.containsMouse
    QQC2.ToolTip.text: i18nc("@info:tooltip", "Check the box to customize")

    // Component
    QQC2.CheckBox {
        id: checkbox
    }
    SpinBox {
        id: spinBox
        Layout.fillWidth: true
        enabled: customized
        suffix: " px"

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
        }
    }
}
