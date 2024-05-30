import QtQuick
import org.kde.kitemmodels as KItemModels
import org.kde.ksysguard.sensors as Sensors
import "../code/graphs.js" as GraphFns

ListModel {
    id: root
    property int _lastCount: 0

    Component.onCompleted: {
        // Add constant graphs (GPU and disks added with "_privateModel")
        ["cpu", "memory", "network"].forEach(type => append(GraphFns.getDisplayInfo(type, i18nc)));
        _lastCount = count;
    }

    function find(type, device) {
        for (let i = 0; i < count; i++) {
            const item = get(i);
            if (item.type === type && item.device === device) {
                return item;
            }
        }
        return undefined;
    }

    // Sensor for retrieve GPU name
    property var _gpuNameFetcher: Sensors.SensorDataModel {
        readonly property var gpuNameRegex: /.*\[(.*)\]/
        property var _cache: (new Map())

        onDataChanged: topLeft => {
            const sensorId = data(topLeft, Sensors.SensorDataModel.SensorId);
            const cache = _cache.get(sensorId);
            if (typeof cache === "undefined") {
                return;
            }
            let deviceName = data(topLeft, Qt.Value);

            // Prevent case when name is not retrieved
            if (deviceName === "") {
                cache.nameRetry += 1;
                _cache.set(sensorId, cache);
                if (cache.nameRetry < 3) {
                    return;
                }

                // Fallback to unknown name
                deviceName = cache.device + ": UNKNOWN";
            } else {
                // Special case for non NVIDIA graphic card (eg. in AMD the name look like "Navi 21 [Radeon RX 6950 XT]")
                const nameMatch = deviceName.match(gpuNameRegex);
                if (nameMatch) {
                    if (nameMatch[1].startsWith("Radeon")) {
                        deviceName = "AMD ";
                    } else {
                        deviceName = "Intel ";
                    }
                    deviceName += nameMatch[1];
                }
            }
            root.set(cache.index, GraphFns.getDisplayInfo("gpu", i18nc, cache.section, cache.device, deviceName));

            // Clean things
            _cache.delete(sensorId);
            if (_cache.size === 0) {
                enabled = false;
            }
        }

        function fetch(sensorId, index, section, device) {
            _cache.set(sensorId, {
                index,
                section,
                device,
                nameRetry: 0
            });
            sensors.push(sensorId);
            sensors = sensors; // hack to update sensors
        }
    }

    property var _privateModel: KItemModels.KSortFilterProxyModel {
        readonly property var sensorsRegex: /^(gpu|disk)\/([a-z0-9\-]+)\/(name|used|usage)?$/

        sourceModel: KItemModels.KDescendantsProxyModel {
            model: Sensors.SensorTreeModel {}
        }

        filterRowCallback: (row, parent) => {
            const sensorId = sourceModel.data(sourceModel.index(row, 0), Sensors.SensorTreeModel.SensorId);
            const matchs = sensorId.match(sensorsRegex);
            if (matchs) {
                switch (matchs[1]) {
                case "cpu":
                    return matchs[2] === "all" && matchs[3] === "name";
                case "memory":
                    return matchs[2] === "physical";
                case "network":
                    return matchs[2] === "all";
                case "gpu":
                    if (matchs[2] === "all") {
                        return matchs[3] === "usage";
                    }
                    return matchs[3] === "name";
                case "disk":
                    if (matchs[2] === "all") {
                        return matchs[3] === "used";
                    }
                    return matchs[3] === "name";
                }
            }
            return false;
        }

        onRowsInserted: (parent, first, last) => {
            for (let i = first; i <= last; ++i) {
                const rowIndex = i + _lastCount;
                // Prevent index out of range
                if (rowIndex > root.count) {
                    return;
                }

                // Retrieve sensor info
                const index = root._privateModel.index(i, 0);
                const sensorId = data(index, Sensors.SensorTreeModel.SensorId);
                let deviceName = data(index, Qt.Value);
                const [_, type, device] = sensorId.match(sensorsRegex);

                // Prevent line when name is not yet retrieved
                if (deviceName === "" || deviceName === "name") {
                    return;
                }

                // Retrieve section name
                let categoryIndex = sourceModel.mapToSource(mapToSource(index));
                let subcategoryIndex = null;
                while (categoryIndex.parent.valid) {
                    subcategoryIndex = categoryIndex;
                    categoryIndex = categoryIndex.parent;
                }
                const section = sourceModel.model.data(categoryIndex, Qt.DisplayRole);

                // Prevent line when section name is not yet retrieved
                if (section === type) {
                    return;
                }

                // Retrieve right device name
                if (device === "all") {
                    deviceName = i18n("All");
                } else if (type === "gpu") {
                    // GPU name need to be fetched by sensor
                    root._gpuNameFetcher.fetch(sensorId, i + _lastCount, section, device);
                } else {
                    deviceName = device;
                }

                // Add graphs
                root.set(i + _lastCount, GraphFns.getDisplayInfo(type, i18nc, section, device, deviceName));
            }
        }

        onRowsRemoved: (parent, first, last) => {
            for (var i = last; i >= first; --i) {
                root.remove(i + _lastCount);
            }
        }
    }
}
