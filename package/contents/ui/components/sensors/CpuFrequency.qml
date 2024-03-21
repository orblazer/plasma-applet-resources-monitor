import QtQuick 2.15
import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.ksysguard.formatter 1.0 as Formatter

// TODO (3.0): remove this
Sensors.SensorDataModel {
    id: root
    property int _coreCount

    property string agregator: "average" // Possible value: average, minimum, maximum
    property bool needManual

    signal ready

    function getFormattedValue() {
        return Formatter.Formatter.formatValueShowNull(getValue(), 302 /* Formatter.Unit.UnitMegaHertz */);
    }

    function getValue() {
        let values = [];
        for (let i = 0; i < _coreCount; i++) {
            values[i] = data(index(0, i), Sensors.SensorDataModel.Value);
        }

        // Agregate values
        if (agregator === "average") {
            return values.reduce((a, b) => a + b, 0) / _coreCount;
        } else if (agregator === "minimum") {
            return Math.min(...values);
        } else if (agregator === "maximum") {
            return Math.max(...values);
        } else {
            return undefined;
        }
    }

    updateRateLimit: -1
    Component.onCompleted: {
        sensors = ["cpu/all/coreCount", "cpu/all/" + agregator + "Frequency"];
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

            // Do nothing if all frequency is already exist
            if (hasIndex(0, 1)) {
                root.enabled = false;
                root.ready();
                return;
            }

            // Fill sensors with all cores
            _coreCount = data(index(0, 0));
            const sensors = [];
            for (let i = 0; i < _coreCount; i++) {
                sensors[i] = "cpu/cpu" + i + "/frequency";
            }
            root.sensors = sensors;
            root.needManual = true;
            root.ready();
        }
    }
}
