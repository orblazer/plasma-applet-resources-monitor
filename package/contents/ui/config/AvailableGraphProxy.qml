import QtQuick
import org.kde.ksysguard.sensors as Sensors
import "../code/graphs.js" as GraphFns

ListModel {
    id: root

    Component.onCompleted: {
        // Add constant graphs (GPU and disks added with "_privateModel")
        ["cpu", "memory", "network"].forEach(type => append(GraphFns.getDisplayInfo(type, i18nc)));
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

    function findAllType(type, excludeAllDevice) {
        const results = [];
        for (let i = 0; i < count; i++) {
            const item = get(i);
            if (item.type !== type) {
                continue;
            } else if (excludeAllDevice && item.device === "all") {
                continue;
            }
            results.push(item);
        }
        return results;
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

    property var _privateModel: Sensors.SensorTreeModel {
        property var foundedSensors: ({})

        onRowsInserted: (parent, first, last) => {
            for (let i = first; i <= last; ++i) {
                const modelIndex = index(i, 0, parent);
                const sensorId = data(modelIndex, Sensors.SensorTreeModel.SensorId);
                const segments = sensorId.split("/");

                // Skip if is not sensor
                if (segments.length != 3) {
                    break;
                }

                // Check if sensor is wanted
                if (test(segments)) {
                    foundedSensors[sensorId] = {
                        index: modelIndex,
                        type: segments[0],
                        device: segments[1]
                    };
                }
            }
        }

        onModelReset: () => {
            // Check if disks have duplicated name and put the display name in sensors list
            const disksNameCount = {};
            for (const [sensorId, sensorData] of Object.entries(foundedSensors)) {
                if (sensorData.type === "disk" && sensorData.device !== "all") {
                    const deviceName = data(sensorData.index.parent, Qt.DisplayRole);
                    disksNameCount[deviceName] = (disksNameCount[deviceName] ?? 0) + 1;
                    foundedSensors[sensorId].deviceName = deviceName;
                }
            }

            // Sort sensors to group by type and sort devices
            const sensors = Object.entries(foundedSensors).sort((a, b) => {
                if (a[1].type === b[1].type) {
                    // Put "all" device in first position
                    if (a[1].device === "all" && b[1].device !== "all") {
                        return -1;
                    } else if (a[1].device !== "all" && b[1].device === "all") {
                        return 1;
                    }

                    // Special case for disks, this put NVMEs first, then disk, then partions, and sort on device name
                    if (a[1].type === "disk") {
                        if (a[1].device.startsWith("nvme") && !b[1].device.startsWith("nvme")) {
                            return -1;
                        } else if (!a[1].device.startsWith("nvme") && b[1].device.startsWith("nvme")) {
                            return 1;
                        }
                        if (a[1].device.startsWith("sd") && !b[1].device.startsWith("sd")) {
                            return -1;
                        } else if (!a[1].device.startsWith("sd") && b[1].device.startsWith("sd")) {
                            return 1;
                        }

                        // Sort devices name
                        if (a[1].deviceName < b[1].deviceName) {
                            return -1;
                        } else if (a[1].deviceName > b[1].deviceName) {
                            return 1;
                        }
                    }

                    // Sort devices
                    if (a[1].device < b[1].device) {
                        return -1;
                    } else if (a[1].device > b[1].device) {
                        return 1;
                    }
                } else if (a[1].type === "gpu" && b[1].type !== "gpu") {
                    return -1;
                } else if (a[1].type !== "gpu" && b[1].type === "gpu") {
                    return 1;
                }

                return 0;
            });

            // Process sensors list
            for (const [sensorId, sensorData] of sensors) {
                // Retrieve section name
                let categoryIndex = sensorData.index;
                let subcategoryIndex = null;
                while (categoryIndex.parent.valid) {
                    subcategoryIndex = categoryIndex;
                    categoryIndex = categoryIndex.parent;
                }
                const section = data(categoryIndex, Qt.DisplayRole);

                // Retrieve device name
                let deviceName = sensorData.device;
                if (sensorData.device === "all") {
                    deviceName = i18n("All");
                } else if (sensorData.type === "disk") {
                    deviceName = sensorData.deviceName;

                    // Add partion ID if name is duplicated
                    if (disksNameCount[deviceName] > 1) {
                        deviceName += ` (${sensorData.device})`;
                    }
                }

                // Add graphs
                root.append(GraphFns.getDisplayInfo(sensorData.type, i18nc, section, sensorData.device, deviceName));

                // Query GPU name from sensor
                if (sensorData.type === "gpu" && sensorData.device !== "all") {
                    root._gpuNameFetcher.fetch(sensorId, root.count - 1, section, sensorData.device);
                }
            }
        }

        function test([type, device, sensor]) {
            // Skip "all" patern sensors
            if (device === "(?!all).*") {
                return false;
            }
            switch (type) {
            case "gpu":
                if (device === "all") {
                    return sensor === "usage";
                }
                return sensor === "name";
            case "disk":
                if (device === "all") {
                    return sensor === "used";
                }
                return sensor === "name";
            }
            return false;
        }
    }
}
