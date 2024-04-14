import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    signal changed // Notify some settings as been changed

    required property var item
}
