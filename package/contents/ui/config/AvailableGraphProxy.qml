import QtQuick
import org.kde.kitemmodels as KItemModels
import org.kde.ksysguard.sensors as Sensors

ListModel {
    id: root

    function findByDevice(value) {
        for (let i = 0; i < count; i++) {
            const item = get(i);
            if (item.device === value) {
                return item;
            }
        }
        return undefined;
    }

    readonly property var graphInfos: {
        "cpu": {
            "name": i18nc("Chart name", "CPU"),
            "icon": "cpu-symbolic"
        },
        "memory": {
            "name": i18nc("Chart name", "Memory"),
            "icon": "memory-symbolic"
        },
        "network": {
            "name": i18nc("Chart name", "Network"),
            "icon": "network-wired-symbolic"
        },
        "gpu": {
            "name": name => i18nc("Chart name", "GPU [%1]", name),
            "icon": "freon-gpu-temperature-symbolic"
        },
        "disk": {
            "name": name => i18nc("Chart name", "Disks I/O [%1]", name),
            "icon": "drive-harddisk-symbolic"
        }
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
                const [_, type, device, sensor] = sensorId.match(sensorsRegex);
                const item = {
                    type,
                    name: "",
                    icon: root.graphInfos[type].icon,
                    section: "",
                    device: type
                };

                // Special case for GPU and disks
                if (type === "gpu" || type === "disk") {
                    let deviceName = data(index, Qt.Value);
                    // Prevent line when name is not yet retrieved
                    if (deviceName === "name") {
                        return;
                    }

                    // Retrieve section name
                    let categoryIndex = sourceModel.mapToSource(mapToSource(index));
                    let subcategoryIndex = null;
                    while (categoryIndex.parent.valid) {
                        subcategoryIndex = categoryIndex;
                        categoryIndex = categoryIndex.parent;
                    }
                    item.section = sourceModel.model.data(categoryIndex, Qt.DisplayRole);

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
                    item.name = root.graphInfos[type].name(deviceName);
                } else {
                    item.name = root.graphInfos[type].name;
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
