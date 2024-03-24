import QtQuick
import org.kde.kitemmodels as KItemModels
import org.kde.ksysguard.sensors as Sensors

KItemModels.KSortFilterProxyModel {
    id: detector
    signal ready

    // Find all gpus
    sourceModel: KItemModels.KDescendantsProxyModel {
        model: Sensors.SensorTreeModel {
        }
    }

    property var _regex: /network\/\w+\/network/
    filterRowCallback: function (row, parent) {
        const sensorId = sourceModel.data(sourceModel.index(row, 0, parent), Sensors.SensorTreeModel.SensorId);
        if (_regex.test(sensorId)) {
            return true;
        }
        return false;
    }

    property var _timer: Timer {
        running: true
        interval: 100

        onTriggered: {
            running = false;
            ready();
        }
    }

    function getInterfaceName(row) {
        const sensortId = data(index(row, 0), Sensors.SensorTreeModel.SensorId);
        if (typeof sensortId === 'undefined') {
            return undefined;
        }
        return sensortId.replace('network/', '').replace('/network', '');
    }
}
