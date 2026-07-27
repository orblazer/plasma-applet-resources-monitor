import QtQuick
import org.kde.ksysguard.sensors as Sensors
import "../code/graphs.js" as GraphFns

ListModel {
    id: root

    signal initialized

    Component.onCompleted: {
        // Add constant graphs (GPU and disks added with "_privateModel")
        ["text", "cpu", "cpuText", "memory", "memoryText", "network", "networkText"].forEach(type => append(GraphFns.getDisplayInfo(type, i18nc)));
        initialized();
    }

    function find(type, device) {
        for (let i = 0; i < count; i++) {
            const item = get(i);
            if ((type == "text" && item.type == "text") || (item.type === type && item.device === device)) {
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
            root.set(cache.index + 1, GraphFns.getDisplayInfo("gpuText", i18nc, cache.section, cache.device, deviceName)); // Text variant

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
            let sensors = Object.entries(foundedSensors);

            // Check if disks have duplicated name and put the display name in sensors list
            const disksNameCount = {};
            for (const [sensorId, sensorData] of sensors) {
                if (sensorData.type === "disk" && sensorData.device !== "all") {
                    const deviceName = data(sensorData.index.parent, Qt.DisplayRole);
                    disksNameCount[deviceName] = (disksNameCount[deviceName] ?? 0) + 1;
                    foundedSensors[sensorId].deviceName = deviceName;
                }
            }

            // Sort sensors to group by type and sort devices
            sensors = sortEntries(sensors);

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
                let type = sensorData.type;
                let deviceName = sensorData.device;
                if (sensorData.device === "all") {
                    deviceName = i18n("All");
                } else if (type === "disk") {
                    deviceName = sensorData.deviceName;

                    // Add partition ID if name is duplicated
                    if (disksNameCount[deviceName] > 1) {
                        deviceName += ` (${sensorData.device})`;
                    }
                } else if (type === "power") {
                    type = "batteryText"; // Change type cause only text variant exist and is only for battery
                    deviceName = data(sensorData.index.parent, Qt.DisplayRole);
                }

                // Add graphs
                root.append(GraphFns.getDisplayInfo(type, i18nc, section, sensorData.device, deviceName));
                // Add text variant
                if (type === "gpu" || type === "disk") {
                    root.append(GraphFns.getDisplayInfo(type + "Text", i18nc, section, sensorData.device, deviceName));
                }

                // Query GPU name from sensor
                if (type === "gpu" && sensorData.device !== "all") {
                    root._gpuNameFetcher.fetch(sensorId, root.count - 2, section, sensorData.device);
                }
            }
        }

        function sortEntries(entries) {
            const typeOrder = {
                power: 0,
                gpu: 1,
                disk: 2
            };
            const compareOptions = {
                numeric: true,
                sensitivity: "base"
            };

            function diskRank(device) {
                if (device === "all")
                    return 0;
                if (device.startsWith("nvme"))
                    return 1;
                if (/^(sd[a-z]|hd[a-z]|vd[a-z]|xvd[a-z]|fd[a-z])(\d+)?$/i.test(device))
                    return 2;
                return 3;
            }

            return entries.sort((rA, rB) => {
                const [, a] = rA;
                const [, b] = rB;

                const typeCmp = (typeOrder[a.type] ?? 99) - (typeOrder[b.type] ?? 99);
                if (typeCmp !== 0)
                    return typeCmp;

                if (a.type === "gpu") {
                    if (a.device === "all" && b.device !== "all")
                        return -1;
                    if (b.device === "all" && a.device !== "all")
                        return 1;
                }

                if (a.type === "disk") {
                    const ra = diskRank(a.device);
                    const rb = diskRank(b.device);
                    if (ra !== rb)
                        return ra - rb;
                }

                return a.device.localeCompare(b.device, undefined, compareOptions);
            });
        }

        function test([type, device, sensor]) {
            // Skip "all" pattern sensors
            if (device === "(?!all).*") {
                return false;
            }
            switch (type) {
            case "gpu":
                if (device === "all") {
                    return sensor === "usage";
                } else if (device === "gpu\\d+") { // Ignore invalid device
                    return false;
                }
                return sensor === "name";
            case "disk":
                if (device === "all") {
                    return sensor === "used";
                }
                return sensor === "name";
            case "power":
                return sensor === "name";
            }

            return false;
        }
    }
}
