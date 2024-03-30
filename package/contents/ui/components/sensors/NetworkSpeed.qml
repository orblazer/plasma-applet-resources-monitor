import QtQuick 2.0
import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.plasma.core 2.1 as PlasmaCore
import "../functions.js" as Functions

/**
 * SRCs:
 * - https://invent.kde.org/plasma/libplasma/-/blob/kf5/src/declarativeimports/core/datasource.h
 * - https://invent.kde.org/plasma/plasma-workspace/-/blob/Plasma/5.27/dataengines/executable/executable.h
 * - https://github.com/dfaust/plasma-applet-netspeed-widget
 */
PlasmaCore.DataSource {
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
            const nextTransferData = Functions.parseTransferData(data.stdout);
            // Skip calculate if is first run
            if (root._previousTs !== 0) {
                const duration = now - root._previousTs;
                value = Functions.calcSpeedData(root._transferData, nextTransferData, duration);
            }
            root._transferData = nextTransferData;
            root._previousTs = now;
        }
    }

    function execute() {
        root.connectSource(Functions.NET_DATA_SOURCE);
    }
}
