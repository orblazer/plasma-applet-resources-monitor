import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

RowLayout {
    id: root
    spacing: Kirigami.Units.largeSpacing

    property alias predefinedChoices: predefinedChoices
    property alias spinBox: spinBox

    property int customValueIndex: 0
    property real factor: 1 // This is for auto convert from Kilo, Mega, etc
    property real realValue

    QQC2.ComboBox {
        id: predefinedChoices
        Layout.fillWidth: true
        currentIndex: -1

        onActivated: {
            // Skip update spin box if user select custom option
            if (currentIndex === customValueIndex) {
                root.realValue = spinBox.realValue;
                return;
            }

            root.realValue = currentValue;

            // Set value from choice in spin box
            spinBox.realValue = valueFromPredefinedChoice(currentValue, currentIndex);
        }

        // Auto select predefined choice
        Component.onCompleted: {
            const index = indexOfValue(realValue);
            currentIndex = index !== -1 ? index : customValueIndex;
        }
    }
    SpinBox {
        id: spinBox
        Layout.fillWidth: true
        Layout.minimumWidth: 120
        visible: predefinedChoices.currentIndex === customValueIndex
        realValue: valueFromPredefinedChoice(root.realValue)

        onRealValueChanged: {
            if (visible) {
                root.realValue = spinBox.realValue * factor;
            }
        }
    }

    property var valueFromPredefinedChoice: (value, index) => value / factor
}
