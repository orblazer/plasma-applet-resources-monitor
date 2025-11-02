import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.formatter as Formatter
import "./base" as RMBase

RMBase.BaseSensorText {
    id: root
    objectName: "CpuText"
    sensor.sensorId: "cpu/all/" + sensorsType[0]
    readonly property int minimumWidth: textContainer.enabled ? Formatter.Formatter.maximumLength(1002 /* Formatter.Unit.UnitPercent */, textContainer.font) : 0

    // Text options
    textContainer {
        displayment: "always"
        valueColors: root.colors

        Component.onCompleted: {
            textContainer.getLabel(0).valueText = "CPU"
        }
    }
}
