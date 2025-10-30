import QtQuick
import org.kde.plasma.plasmoid
import "./base" as RMBase

RMBase.BaseSensorText {
    id: root
    objectName: "CpuText"
    sensor.sensorId: "cpu/all/" + sensorsType[0]

    // Text options
    textContainer {
        displayment: "always"
        valueColors: root.colors

        Component.onCompleted: {
            textContainer.getLabel(0).valueText = "CPU"
        }
    }
}
