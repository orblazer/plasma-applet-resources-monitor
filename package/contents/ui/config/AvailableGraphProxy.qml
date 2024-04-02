import QtQuick
import org.kde.kitemmodels as KItemModels
import org.kde.ksysguard.sensors as Sensors
import "../code/graphs.js" as GraphFns

ListModel {
    id: root

    function find(type, device) {
        for (let i = 0; i < count; i++) {
            const item = get(i);
            if (item.type === type && item.device === device) {
                return item;
            }
        }
        return undefined;
    }

    property var _privateModel: KItemModels.KSortFilterProxyModel {
        readonly property var sensorsRegex: /^(cpu|memory|gpu|network|disk)\/([a-z0-9\-]+)\/(name|used|usage|download)$/
        readonly property var gpuNameRegex: /.*\[(.*)\]/

        sourceModel: KItemModels.KDescendantsProxyModel {
            model: Sensors.SensorTreeModel {
            }
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
                // Ignore when outside range
                // Rows are initially inserted strangely, so this suppresses errors
                // and everything comes out working anyway
                if (i > root.count) {
                    return;
                }

                // Retrieve sensor info
                const index = _privateModel.index(i, 0);
                const sensorId = data(index, Sensors.SensorTreeModel.SensorId);
                let deviceName = data(index, Qt.Value);

                // Prevent line when name is not yet retrieved
                if (deviceName === "" || deviceName === "name") {
                    return;
                }

                // Retrieve informations
                const [_, type, device, sensor] = sensorId.match(sensorsRegex);
                const graphInfo = GraphFns.getInfo(type)
                const item = {
                    type,
                    name: graphInfo?.name,
                    icon: graphInfo?.icon,
                    section: "",
                    device: type
                };

                // Special case for GPU and disks
                if (type === "gpu" || type === "disk") {
                    // Retrieve section name
                    let categoryIndex = sourceModel.mapToSource(mapToSource(index));
                    let subcategoryIndex = null;
                    while (categoryIndex.parent.valid) {
                        subcategoryIndex = categoryIndex;
                        categoryIndex = categoryIndex.parent;
                    }
                    item.section = sourceModel.model.data(categoryIndex, Qt.DisplayRole);
                    // Prevent line when name is not yet retrieved
                    if (item.section === type) {
                        return;
                    }

                    // Retrieve right device name
                    if (device === "all") {
                        deviceName = i18n("All");
                    } else if (type === "gpu") {
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
                    } else {
                        deviceName = device;
                    }

                    // Apply variables
                    item.device = device;
                    item.name = graphInfo.name(deviceName);
                }
                root.set(i, item);
            }
        }

        onRowsRemoved: (parent, first, last) => {
            for (var i = last; i >= first; --i) {
                availableSensorsModel.remove(i);
            }
        }
    }
}
