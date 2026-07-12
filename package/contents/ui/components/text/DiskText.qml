import QtQuick
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter
import "./base" as RMBase

RMBase.BaseSensorText {
    id: root
    objectName: "DiskText"
    sensorsFormat: [isIO ? Formatter.Units.UnitByteRate : (fieldInPercent ? Formatter.Units.UnitPercent : Formatter.Units.UnitByte)]

    // Settings
    property string device: "all" // Device ID (e.g.: "sda" or "sdc"); could be "all"
    property bool icons: false

    // Config shortcut
    readonly property bool isIO: sensorsType[0].includes("io")
    readonly property bool fieldInPercent: sensorsType[0].endsWith("-percent")
    readonly property bool isIOReverse: sensorsType[0] == "io-reverse"

    // Retrieve chart index and swap it if needed
    readonly property int readIndex: isIOReverse ? 1 : 0
    readonly property int writeIndex: isIOReverse ? 0 : 1

    // Value options - use used sensor to get disk usage
    sensor.enabled: !isIO
    sensor.sensorId: `disk/${device}/used`

    // Text options
    alwaysTitle: isIO ? false : titleWhen === "always"
    textContainer {
        lineCount: 2

        hints: {
            if (isIO) {
                const read = i18nc("Graph label", "Read");
                const write = i18nc("Graph label", "Write");
                return isIOReverse ? [write, read, ""] : [read, write, ""];
            } else {
                return alwaysTitle ? [" ", " ", ""] : [title, "", ""];
            }
        }
    }

    // Override methods, for handle disk in percent
    _update: () => {
        // Show icons
        if (root.isIO) {
            for (let index = 0; index < 2; ++index) {
                let icon = "";
                if (root.icons) {
                    if (index === readIndex) {
                        icon = "\u2009" + i18nc("Disk graph icon : Read", "R");
                    } else if (index == writeIndex) {
                        icon = "\u2009" + i18nc("Disk graph icon : Write", "W");
                    }
                }

                const value = maxQueryModel.getData(index)
                textContainer.setValue(index, value, Formatter.Formatter.formatValueShowNull(value, Formatter.Units.UnitByteRate) + icon);
            }
        } else {
            const value = sensor.getValue();

            let text = "";
            if (fieldInPercent) {
                text = i18nc("Percent unit", "%1%", Math.round((value / maxQueryModel.maxUsage) * 1000) / 10); // This is for round to 1 decimal
            } else {
                text = _defaultFormatValue(0, value);
            }
            textContainer.setValue(alwaysTitle ? 1 : 0, value, text);
        }
    }

    // Initialize limits
    Sensors.SensorDataModel {
        id: maxQueryModel
        updateRateLimit: -1
        sensors: isIO ? (sensorsType[0] == "io" ? [`disk/${device}/write`, `disk/${device}/read`] : [`disk/${device}/read`, `disk/${device}/write`]) : [`disk/${device}/total`]

        // Update limit when is usage
        property var maxUsage: -1
        onDataChanged: topLeft => {
            // Update values
            const value = parseInt(data(topLeft, Sensors.SensorDataModel.Value));
            if (isNaN(value) || (topLeft.column === 0 && value <= 0)) {
                return;
            }

            if (sensors.length == 1) {
                maxUsage = value;
                enabled = false;
            }
        }

        function getData(column, role = Sensors.SensorDataModel.Value) {
            if (!hasIndex(0, column)) {
                console.log("variable")
                return undefined;
            }
            return data(index(0, column), role);
        }
    }
}
