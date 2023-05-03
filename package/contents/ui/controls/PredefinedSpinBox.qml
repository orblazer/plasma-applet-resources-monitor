import QtQuick 2.0
import QtQuick.Layouts 1.15 as QtLayouts
import QtQuick.Controls 2.0 as QQC2
import org.kde.kirigami 2.6 as Kirigami
import "./" as RMControls

QtLayouts.RowLayout {
    spacing: Kirigami.Units.largeSpacing

    property alias predefinedChoices: predefinedChoices
    property alias spinBox: spinBox

    property int customValueIndex: 0
    property real factor: 1 // This is for auto convert from Kilo, Mega, etc

    property real value: Math.round(realValue / factor)
    property real realValue

    Component.onCompleted: {
        // Initialize spin real value
        spinBox.realValue = value;

        // Bind "realValue" to "spinBox.realValue" and "factor"
        realValue = Qt.binding(() => spinBox.realValue * factor);
    }

    QQC2.ComboBox {
        id: predefinedChoices
        QtLayouts.Layout.fillWidth: true
        currentIndex: -1

        onCurrentIndexChanged: {
            // Skip update spin box if user select custom option
            if (currentIndex === customValueIndex) {
                return;
            }

            // Set value from choice in spin box (for have only one place to manage value)
            var current = model[currentIndex];
            if (current && current.value !== -1) {
                spinBox.realValue = valueFromPredefinedChoice(current);
            }
        }

        // Auto select predefined choice
        Component.onCompleted: {
            const index = indexOfValue(realValue);
            currentIndex = index !== -1 ? index : customValueIndex;
        }
    }
    RMControls.SpinBox {
        id: spinBox
        QtLayouts.Layout.fillWidth: true
        visible: predefinedChoices.currentIndex === customValueIndex
    }

    property var valueFromPredefinedChoice: data => data.value / factor
}
