import QtQuick.Controls as QQC2
import org.kde.plasma.private.quicklaunch

QQC2.Button {
    id: root
    onClicked: open()

    property var value
    property var _data

    onValueChanged: _data = quickLaunch.launcherData(value)

    text: _data ? _data.applicationName : i18n("Choose application...")
    icon.name: _data?.iconName

    QQC2.ToolTip.visible: hovered
    QQC2.ToolTip.text: i18nc("@info:tooltip", "Click to select another application")

    function open() {
        quickLaunch.addLauncher();
    }

    Logic {
        id: quickLaunch
        onLauncherAdded: url => root.value = url
    }
}
