import QtQuick
import org.kde.plasma.plasmoid
import "./base" as RMBase

RMBase.BaseSensorText {
    id: root
    objectName: "GpuText"
    sensor.sensorId: `gpu/${device}/usage`

    // Settings
    property string device: "gpu0" // Device index (eg: gpu0, gpu1)

    // Text options
    textContainer {
        displayment: "always"
        firstLine.text: "GPU"
        valueColors: root.colors
    }
}
