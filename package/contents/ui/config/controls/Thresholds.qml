import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../controls" as RMControls

RowLayout {
    id: root
    spacing: Kirigami.Units.largeSpacing

    property alias warningSpinBox: warningSpinBox
    property alias criticalSpinBox: criticalSpinBox

    // Properties
    property var values: []
    property int decimals: 0
    property int stepSize: 1
    property real realFrom: 0
    property real realTo
    property string suffix: ""

    Component.onCompleted: {
        warningSpinBox.realValue = values[0]
        criticalSpinBox.realValue = values[1]
    }

    RMControls.SpinBox {
        id: warningSpinBox
        Layout.fillWidth: true
        Layout.fillHeight: true
        QQC2.ToolTip.visible: hovered
        QQC2.ToolTip.text: i18nc("@info:tooltip", "Warning threshold")

        // realValue: root.values[0]
        onRealValueChanged: {
            root.values[0] = realValue
            root.valuesChanged()
        }

        decimals: root.decimals
        stepSize: root.stepSize
        realFrom: root.realFrom
        realTo: root.realTo
        suffix: root.suffix
    }

    RMControls.SpinBox {
        id: criticalSpinBox
        Layout.fillWidth: true
        Layout.fillHeight: true
        QQC2.ToolTip.visible: hovered
        QQC2.ToolTip.text: i18nc("@info:tooltip", "Critical threshold")

        // realValue: values[1]
        onRealValueChanged: {
            root.values[1] = realValue
            root.valuesChanged()
        }

        decimals: root.decimals
        stepSize: root.stepSize
        realFrom: root.realFrom
        realTo: root.realTo
        suffix: root.suffix
    }
}
