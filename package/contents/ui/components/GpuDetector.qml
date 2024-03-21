import QtQuick 2.15
import org.kde.kitemmodels 1.0 as KItemModels
import org.kde.ksysguard.sensors 1.0 as Sensors

KItemModels.KSortFilterProxyModel {
    id: detector

    property var model: []
    property var _privateModel: ListModel {
    }

    signal ready

    // Find all gpus
    sourceModel: KItemModels.KDescendantsProxyModel {
        model: Sensors.SensorTreeModel {
        }
    }

    property var _regex: /gpu\/(gpu\d)\/name/
    property var _tmpSensors: []
    filterRowCallback: function (row, parent) {
        const sensorId = sourceModel.data(sourceModel.index(row, 0), Sensors.SensorTreeModel.SensorId);
        const found = sensorId.match(_regex);
        if (found && _tmpSensors.findIndex(item => item === sensorId) === -1) {
            _tmpSensors.push(sensorId);
            _privateModel.append({
                    "index": found[1],
                    "name": ""
                });
        }
    }

    // Find name of GPU
    property var _nameRegex: /.*\[(.*)\]/
    property var _sensors: Sensors.SensorDataModel {
        updateRateLimit: -1
        property var retrievedData: 0

        onDataChanged: {
            let name = data(topLeft, Sensors.SensorDataModel.Value);

            // Special case for non NVIDIA graphic card (eg. in AMD the name look like "Navi 21 [Radeon RX 6950 XT]")
            const found = name.match(_nameRegex);
            if (found) {
                if (found[1].startsWith("Radeon")) {
                    name = "AMD ";
                } else {
                    name = "Intel ";
                }
                name += found[1];
            }
            _privateModel.setProperty(topLeft.column, "name", name);

            // Stop sensors and update model
            if (++retrievedData === sensors.length) {
                enabled = false;
                detector.model = _privateModel;
                detector.ready();
            }
        }
    }

    property var _timer: Timer {
        running: true
        triggeredOnStart: true

        onTriggered: {
            running = false;
            _sensors.sensors = _tmpSensors;
        }
    }
}
