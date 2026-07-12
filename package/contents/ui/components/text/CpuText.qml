import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.formatter as Formatter
import "./base" as RMBase

RMBase.BaseSensorText {
    id: root
    objectName: "CpuText"
    sensor.sensorId: "cpu/all/" + sensorsType[0]
    sensorsFormat: [Formatter.Units.UnitPercent]
}
