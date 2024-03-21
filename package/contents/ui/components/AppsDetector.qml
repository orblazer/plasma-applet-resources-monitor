import QtQuick 2.15
import org.kde.plasma.core 2.1 as PlasmaCore

PlasmaCore.SortFilterModel {
    id: detector

    sourceModel: PlasmaCore.DataModel {
        dataSource: PlasmaCore.DataSource {
            engine: "apps"
            connectedSources: {
                // Explude folder
                var result = [];
                for (var i = 0; i < sources.length; i++) {
                    if (sources[i].endsWith(".desktop")) {
                        result.push(sources[i]);
                    }
                }
                return result;
            }
            interval: 0
        }
    }

    sortRole: "name"
    sortOrder: Qt.AscendingOrder

    filterCallback: function (row, value) {
        const search = filterString.toLowerCase();
        if (search.length === 0) {
            return true;
        }
        const item = sourceModel.get(row);
        if (item.name.toLowerCase().includes(search) || item.menuId.replace(".desktop", "").toLowerCase().includes(search)) {
            return true;
        }
        return false;
    }

    function findIndex(menuId) {
        for (var i = 0; i < count; i++) {
            if (get(i).menuId === menuId) {
                return i;
            }
        }
        return -1;
    }
}
