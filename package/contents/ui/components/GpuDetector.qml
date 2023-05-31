import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.ksysguard.sensors 1.0 as Sensors

QtObject {
    id: detector

    property var model: []
    property var _privateModel: ListModel {
    }

    signal ready

    property var _dataSource: PlasmaCore.DataSource {
        engine: "executable"
        connectedSources: []

        onNewData: {
            const count = parseInt(data["stdout"].trim().split(':')[0]);

            // List sensors and init model data
            const sensors = [];
            for (let i = 0; i < count; i++) {
                sensors.push("gpu/gpu" + i + "/name");
                _privateModel.append({
                        "index": "gpu" + i,
                        "name": ""
                    });
            }
            _sensors.sensors = sensors;
            disconnectSource(sourceName); // cmd finished
        }

        Component.onCompleted: {
            connectSource("lspci | grep ' VGA ' | tail -n 1 | cut -d' ' -f 1");
        }
    }

    property var _sensors: Sensors.SensorDataModel {
        updateRateLimit: -1
        property var retrievedData: 0

        onDataChanged: {
            _privateModel.setProperty(topLeft.column, "name", data(topLeft, Sensors.SensorDataModel.Value));

            // Stop sensors and update model
            if (++retrievedData === sensors.length) {
                enabled = false;
                detector.model = _privateModel;
                detector.ready()
            }
        }
    }
}
