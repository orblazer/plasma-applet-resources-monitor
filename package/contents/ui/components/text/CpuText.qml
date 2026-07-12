import QtQuick
import org.kde.ksysguard.formatter as Formatter
import "./base" as RMBase
import "../sensors" as RMSensors

RMBase.BaseSensorText {
    id: root
    objectName: "CpuText"
    readonly property bool isTemperature: sensorsType[0] == "temperature"

    sensorsFormat: [Formatter.Units.UnitPercent]
    _update: () => {
        root._defaultUpdate();
        cpuTemperature.update();
    }

    sensor.enabled: !isTemperature
    sensor.sensorId: "cpu/all/" + sensorsType[0]

    // Temperature handle
    _formatValue: (index, value) => {
        if (isTemperature) {
            return cpuTemperature.getFormattedValue();
        }
        return _defaultFormatValue(index, value);
    }

    RMSensors.CpuTemperature {
        id: cpuTemperature
        enabled: isTemperature
    }
}
