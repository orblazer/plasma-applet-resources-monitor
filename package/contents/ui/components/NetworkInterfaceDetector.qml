import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

QtObject {
    id: detector

    property var model: []

    property var _dataSource: PlasmaCore.DataSource {
        id: dataSource
        engine: "executable"
        connectedSources: []

        property var excludedInterface: /^(?!lo|bridge|usbus|bond)(.*)$/

        onNewData: {
            var interfaces = data["stdout"].trim().split('\n');
            for (var i = 0; i < interfaces.length; i++) {
                if (excludedInterface.test(interfaces[i])) {
                    _privateModel.append({
                            "name": interfaces[i]
                        });
                }
            }
            detector.model = _privateModel;
            disconnectSource(sourceName); // cmd finished
        }

        Component.onCompleted: {
            connectSource("ip -o link show | awk -F': ' '{print $2}'");
        }
    }

    property var _privateModel: ListModel {}
}
