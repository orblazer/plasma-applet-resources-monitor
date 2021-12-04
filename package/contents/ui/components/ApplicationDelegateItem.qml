import QtQuick 2.0
import QtQuick.Controls 2.12 as QtControls
import QtQuick.Layouts 1.1 as QtLayouts
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.6 as Kirigami

MouseArea {
  id: root
  height: childrenRect.height

  hoverEnabled: true
  cursorShape: Qt.PointingHandCursor

  property string serviceName: ""
  property string name: ""
  property string comment: ""
  property string iconName: ""
  property bool selected: false

  QtLayouts.RowLayout {
      spacing: Kirigami.Units.smallSpacing

      QtControls.ToolTip.text: (comment !== "" ? comment + "\n\n" : "") +
        "ID: " + serviceName + ".desktop"
      QtControls.ToolTip.visible: root.containsMouse

      PlasmaCore.IconItem {
          id: icon

          source: iconName
          implicitHeight: 16
          implicitWidth: 16
      }
      PlasmaComponents.Label {
          text: selected ? "<strong>" + name + "</strong>" : name
      }
  }
}
