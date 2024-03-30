import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

RowLayout {
    spacing: Kirigami.Units.largeSpacing

    property alias predefinedChoices: predefinedChoices
    property alias spinBox: spinBox

    property int customValueIndex: 0
    property real factor: 1 // This is for auto convert from Kilo, Mega, etc
    property real realValue

    Component.onCompleted: {
        // Initialize spin real value
        spinBox.realValue = realValue / factor;

        // Bind "realValue" to "spinBox.realValue" and "factor"
        realValue = Qt.binding(() => spinBox.realValue * factor);
    }

    QQC2.ComboBox {
        id: predefinedChoices
        Layout.fillWidth: true
        currentIndex: -1

        onActivated: {
            // Skip update spin box if user select custom option
            if (currentIndex === customValueIndex) {
                return;
            }

            // Set value from choice in spin box (for have only one place to manage value)
            if (currentValue !== -1) {
                spinBox.realValue = valueFromPredefinedChoice(currentValue, currentIndex);
            }
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
    }

    property var valueFromPredefinedChoice: (value, index) => value / factor
}
