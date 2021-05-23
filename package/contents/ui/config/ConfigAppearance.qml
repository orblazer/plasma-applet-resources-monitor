import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {

    property alias cfg_verticalLayout: verticalLayout.checked
    property alias cfg_enableHints: enableHints.checked
    property alias cfg_enableShadows: enableShadows.checked
    property alias cfg_fontScale: fontScale.value

    GridLayout {
        Layout.fillWidth: true
        columns: 2

        Label {
            text: i18n('Font scale:')
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: fontScale
            minimumValue: 1
            maximumValue: 100
            suffix: i18nc('Percent', '%')
        }

        // Layout

        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }

        CheckBox {
            id: verticalLayout
            Layout.columnSpan: 2
            text: i18n('Vertical layout')
        }

        CheckBox {
            id: enableHints
            Layout.columnSpan: 2
            text: i18n('Enable hints')
        }

        CheckBox {
            id: enableShadows
            Layout.columnSpan: 2
            text: i18n('Drop shadows')
        }
    }

}
