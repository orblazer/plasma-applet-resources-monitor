import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.ksysguard.formatter as Formatter

// This component use "upwer". Documentation : https://upower.freedesktop.org/docs/Device.html
Item {
    id: root

    required property string device
    required property string metric // Available: percentage, energy-rate, time
    property int interval: 30000 // By default interval is to 30s

    property string batteryState: "unknown" // Values: unknown, charging, discharging, empty, fully-charged (battery at 100%), pending-charge (plugged, but not charging), pending,discharge (discharge when plugged)
    property bool isPresent: false
    property int value: NaN

    readonly property int unit: metric === "percentage" ? Formatter.Units.UnitPercent : (metric === "energy-rate" ? Formatter.Units.UnitWatt : -1)
    readonly property bool isPlugged: (batteryState === "charging" || batteryState === "empty" || batteryState === "fully-charged" || batteryState === "pending-charge")

    // Regex + conversions rules per metric, avoids repeating if/else blocks
    readonly property var _rules: ({
            "percentage": {
                regex: /percentage:\s+(\d+)%/,
                convert: m => parseInt(m[1], 10)
            },
            "energy-rate": {
                regex: /energy-rate:\s+([\d.]+)\s*W/,
                convert: m => parseFloat(m[1])
            },
            "time": {
                regex: /time to (?:empty|full):\s+([\d.]+)\s*(days|hours|minutes|seconds)/,
                convert: m => {
                    const factor = {
                        days: 86400 // 60 * 60 * 24
                        ,
                        hours: 3600 // 60 * 60
                        ,
                        minutes: 60,
                        seconds: 1
                    }[m[2]];
                    return Math.round(parseFloat(m[1]) * factor);
                }
            }
        })

    onMetricChanged: executableSource.execute()
    onDeviceChanged: executableSource.execute()

    Plasma5Support.DataSource {
        id: executableSource
        engine: "executable"

        function execute() {
            disconnectSource("upower -d");
            connectSource("upower -d");
        }

        onNewData: (sourceName, data) => {
            if (sourceName !== "upower -d" || !data["stdout"])
                return;

            const sanitizedDevice = root.device.replace(/:/g, "_");
            const block = data["stdout"].split("Device: ").find(d => d.includes(sanitizedDevice));
            if (!block)
                return;
            root.isPresent = true;

            // Extract battery state
            const stateMatch = block.match(/state:\s+([a-zA-Z0-9-]+)/);
            root.batteryState = stateMatch ? stateMatch[1] : "unknown";

            // Extract requested info
            const rule = root._rules[root.metric];
            const match = rule ? block.match(rule.regex) : null;
            root.value = match ? rule.convert(match) : -1;
        }
    }

    // Refresh timer
    Timer {
        interval: root.interval
        running: interval > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: executableSource.execute()
    }
}
