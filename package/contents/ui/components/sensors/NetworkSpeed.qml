import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support
import "../../code/network.js" as NetworkUtils

/**
 * SRCs:
 * - https://invent.kde.org/plasma/plasma5support/-/blob/master/src/declarativeimports/datasource.h
 * - https://invent.kde.org/plasma/plasma-workspace/-/blob/master/dataengines/executable/executable.h
 * - https://github.com/dfaust/plasma-applet-netspeed-widget
 */
Plasma5Support.DataSource {
    id: root
    engine: 'executable'

    // Format: {"interface":[tx,rx]} (in kilobytes)
    property var value: {
    }

    // Cache for calculate
    property real _previousTs: 0
    property var _transferData: {
    } // Format: {"interface":[tx,rx]} (in bytes)

    // Retrieve data
    onNewData: (sourceName, data) => {
        // run just once (reconnected when update)
        connectedSources.length = 0;
        if (data['exit code'] > 0) {
            print(data.stderr);
        } else {
            const now = Date.now();
            const nextTransferData = NetworkUtils.parseTransferData(data.stdout);
            // Skip calculate if is first run
            if (root._previousTs !== 0) {
                const duration = now - root._previousTs;
                value = NetworkUtils.calcSpeedData(root._transferData, nextTransferData, duration);
                // root.valueChanged();
            }
            root._transferData = nextTransferData;
            root._previousTs = now;
        }
    }

    function execute() {
        root.connectSource(NetworkUtils.NET_DATA_SOURCE);
    }
}
