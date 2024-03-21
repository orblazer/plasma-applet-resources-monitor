import QtQuick 2.2
import org.kde.kirigami 2.6 as Kirigami
import "./" as RMControls

RMControls.SpinBox {
    id: customizableSize

    property bool customized

    // Customized checkbox
    enabled: Kirigami.FormData.checked
    Kirigami.FormData.checkable: true
    Kirigami.FormData.checked: customized
    onEnabledChanged: customized = enabled
}
