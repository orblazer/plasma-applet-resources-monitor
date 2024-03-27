import QtQuick
import QtQuick.Layouts as QtLayouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "./" as RMControls

QtLayouts.RowLayout {
    spacing: Kirigami.Units.smallSpacing

    property alias checkbox: checkbox
    property alias spinBox: spinBox

    property alias customized: checkbox.checked
    property alias value: spinBox.realValue

    QQC2.ToolTip.visible: ma.containsMouse
    QQC2.ToolTip.text: i18n("Check the box to customize")

    // Component
    QQC2.CheckBox {
        id: checkbox
    }
    RMControls.SpinBox {
        id: spinBox
        QtLayouts.Layout.fillWidth: true
        enabled: customized
        suffix: " px"

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
        }
    }
}
