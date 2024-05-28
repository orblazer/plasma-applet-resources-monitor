import QtQuick
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter

Sensors.SensorDataModel {
    id: root
    updateRateLimit: -1

    property int _coreCount: 0

    property string aggregator: "average" // Possible value: average, minimum, maximum
    property int eCoresCount: 0

    signal ready

    function getFormattedValue(eCores = false) {
        return Formatter.Formatter.formatValueShowNull(getValue(eCores), 302 /* Formatter.Unit.UnitMegaHertz */);
    }

    function getValue(eCores = false) {
        if (_coreCount === 0) {
            return undefined;
        }
        const pCoresCount = _coreCount - eCoresCount;

        // Retrieve cores frequencies
        let values = [];
        const start = eCores ? pCoresCount : 0;
        const end = eCores ? _coreCount : pCoresCount;
        for (let i = start; i < end; i++) {
            values[i] = data(index(0, i), Sensors.SensorDataModel.Value);
        }
        if (values.length == 0) {
            return undefined;
        }

        // Agregate values
        if (aggregator === "average") {
            return values.reduce((a, b) => a + b, 0) / values.length;
        } else if (aggregator === "minimum") {
            return Math.min(...values);
        } else if (aggregator === "maximum") {
            return Math.max(...values);
        }
        return undefined;
    }

    // Initialize sensors by retrieving core count, then set to N frequency sensor
    sensors: ["cpu/all/coreCount"]
    readonly property Timer _initialize: Timer {
        running: enabled
        triggeredOnStart: true

        // Wait to be sure all sensors metadata has retrieved
        repeat: true
        interval: 100

        onTriggered: {
            // Prevent error if metadata is not yet retrieved
            if (!root.hasIndex(0, 0)) {
                return;
            }
            const valueVar = parseInt(root.data(root.index(0, 0), Sensors.SensorDataModel.Value));
            if (isNaN(valueVar) || valueVar <= 0) {
                return;
            }

            // Stop running if data is available
            _initialize.running = false;

            // Fill sensors with all cores
            _coreCount = valueVar
            const sensors = [];
            for (let i = 0; i < _coreCount; i++) {
                sensors[i] = "cpu/cpu" + i + "/frequency";
            }
            root.sensors = sensors;
            root.ready();
        }
    }
}
