import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../controls" as RMControls

RowLayout {
    id: root
    spacing: Kirigami.Units.largeSpacing

    property alias warningSpinBox: warningSpinBox
    property alias criticalSpinBox: criticalSpinBox
    property alias valueToText: warningSpinBox.valueToText

    // Properties
    property var values: []
    property int decimals: 0
    property int stepSize: 1
    property real minimumValue: 0
    property real maximumValue
    property var textFromValue: valueToText

    Component.onCompleted: {
        warningSpinBox.realValue = values[0]
        criticalSpinBox.realValue = values[1]
    }

    RMControls.SpinBox {
        id: warningSpinBox
        Layout.fillWidth: true
        Layout.fillHeight: true
        QQC2.ToolTip.text: i18n("Warning threshold")
        QQC2.ToolTip.visible: hovered

        // realValue: root.values[0]
        onRealValueChanged: {
            root.values[0] = realValue
            root.valuesChanged()
        }

        decimals: root.decimals
        stepSize: root.stepSize
        minimumValue: root.minimumValue
        maximumValue: root.maximumValue
        textFromValue: root.textFromValue
    }

    RMControls.SpinBox {
        id: criticalSpinBox
        Layout.fillWidth: true
        Layout.fillHeight: true
        QQC2.ToolTip.text: i18n("Critical threshold")
        QQC2.ToolTip.visible: hovered

        // realValue: values[1]
        onRealValueChanged: {
            root.values[1] = realValue
            root.valuesChanged()
        }

        decimals: root.decimals
        stepSize: root.stepSize
        minimumValue: root.minimumValue
        maximumValue: root.maximumValue
        textFromValue: root.textFromValue
    }
}
