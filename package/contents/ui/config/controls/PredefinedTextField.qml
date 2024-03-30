import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

ColumnLayout {
    spacing: Kirigami.Units.largeSpacing

    property alias predefinedChoices: predefinedChoices
    property alias textField: textField
    property alias text: textField.text

    property int customValueIndex: 0

    QQC2.ComboBox {
        id: predefinedChoices
        Layout.fillWidth: true
        currentIndex: -1

        onActivated: {
            // Skip update textfield if user select custom option
            if (currentIndex === customValueIndex) {
                return;
            }

            // Set value from choice in textfield (for have only one place to manage value)
            text = currentValue;
        }

        // Auto select predefined choice
        Component.onCompleted: {
            const index = indexOfValue(text);
            currentIndex = index !== -1 ? index : customValueIndex;
        }
    }
    QQC2.TextField {
        id: textField
        Layout.fillWidth: true
        visible: predefinedChoices.currentIndex === customValueIndex
    }
}
