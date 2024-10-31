import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: root

    property real value: 0
    property int _failedAttempt: 0

    signal ready

    function update() {
        let value;
        if (_sensor.enabled) {
            value = _sensor.getValue();
            if (value != null) {
                root.value = value;
                return;
            } else if (_failedAttempt++ > 5) {
                // Disable official try if not exist
                _sensor.enabled = false;
            }
        }
        _fallback.execute();
    }

    function getFormattedValue() {
        // return Formatter.Formatter.formatValueWithPrecision(value, 1000 /* Formatter.Unit.UnitCelsius */,
        //         Plasmoid.configuration.thirdLineToLeftTopCorner ? 0 : 1);
        // // There should be `QString KSysGuard::FormatterWrapper::formatValueWithPrecision`, according to https://api.kde.org/plasma/libksysguard/html/classKSysGuard_1_1FormatterWrapper.html,
        // // However in my environment this function does not exists. So, as workaround, I manually implements the precision control as below.

        let result = Formatter.Formatter.formatValueShowNull(value, 1000 /* Formatter.Unit.UnitCelsius */);
        if (Plasmoid.configuration.thirdLineToLeftTopCorner) {
            let [_, resultNumber, resultUnit] = result.match(/(-?[\d.]+)(.*)/)
            resultNumber = Number(resultNumber).toFixed(0)
            result = resultNumber + resultUnit
        }
        return result
    }

    readonly property var _sensor: Sensors.Sensor {
        enabled: root.enabled
        updateRateLimit: -1
        sensorId: "cpu/all/maximumTemperature"

        function getValue() {
            if (value !== 0) {
                return value;
            }
            return null;
        }
    }

    /**
     * SRCs:
     * - https://invent.kde.org/plasma/plasma5support/-/blob/master/src/declarativeimports/datasource.h
     * - https://invent.kde.org/plasma/plasma-workspace/-/blob/master/dataengines/executable/executable.h
     */
    readonly property var _fallback: Plasma5Support.DataSource {
        engine: 'executable'

        property var value: 0

        // Retrieve data
        onNewData: (sourceName, data) => {
            // run just once (reconnected when update)
            connectedSources.length = 0;
            if (data['exit code'] > 0) {
                if (data.stderr === "Specified sensor(s) not found!\n") {
                    return;
                } else if (data.stderr === "/bin/sh: line 1: sensors: command not found\n") {
                    return;
                }
                print(data.stderr);
            } else {
                const output = JSON.parse(data.stdout);
                const sensor = output[Object.keys(output)[0]];
                if (typeof sensor["Tdie"] !== "undefined") {
                    root.value = _getValue(sensor["Tdie"]);
                } else if (typeof sensor["Tctl"] !== "undefined") {
                    root.value = _getValue(sensor["Tctl"]);
                }
            }
        }

        function execute() {
            connectSource("sensors -j 'zenpower-pci-*'");
        }

        function _getValue(entry) {
            for (const key in entry) {
                if (/temp\d_input/.test(key)) {
                    return entry[key];
                }
            }
            return 0;
        }
    }
}
