import QtQuick 2.15
import org.kde.kirigami 2.20 as Kirigami
import "./" as RMControls

RMControls.SpinBox {
    id: customizableSize

    property bool customized

    // Customized checkbox
    enabled: Kirigami.FormData.checked
    Kirigami.FormData.checkable: true
    Kirigami.FormData.checked: customized
    onEnabledChanged: customized = enabled

    // Component
    textFromValue: function (value, locale) {
        return valueToText(value, locale) + " px";
    }
}
