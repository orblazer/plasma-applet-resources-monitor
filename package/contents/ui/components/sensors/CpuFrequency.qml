import QtQuick 2.15
import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.ksysguard.formatter 1.0 as Formatter

Sensors.SensorDataModel {
    id: root
    property int _coreCount

    property string agregator: "average" // Possible value: average, minimum, maximum

    signal ready

    function getFormattedValue(eCores = false) {
        return Formatter.Formatter.formatValueShowNull(getValue(eCores), 302 /* Formatter.Unit.UnitMegaHertz */);
    }

    function getValue(eCores = false) {
        const pCoresCount = _coreCount - plasmoid.configuration.cpuECoresCount;
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
        if (agregator === "average") {
            return values.reduce((a, b) => a + b, 0) / values.length;
        } else if (agregator === "minimum") {
            return Math.min(...values);
        } else if (agregator === "maximum") {
            return Math.max(...values);
        }
        return undefined;
    }

    updateRateLimit: -1
    Component.onCompleted: {
        sensors = ["cpu/all/coreCount"];
    }

    property bool _initialized
    property Timer _timer: Timer {
        running: enabled
        interval: 100 // Wait to be sure all sensors metadata has retrieved

        onTriggered: {
            /// Prevent running multiple times
            if (_initialized) {
                return;
            }
            _initialized = true;

            // Fill sensors with all cores
            _coreCount = data(index(0, 0));
            const sensors = [];
            for (let i = 0; i < _coreCount; i++) {
                sensors[i] = "cpu/cpu" + i + "/frequency";
            }
            root.sensors = sensors;
            root.ready();
        }
    }
}
