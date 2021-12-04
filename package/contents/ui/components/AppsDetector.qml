import QtQuick 2.0
import org.kde.plasma.core 2.1 as PlasmaCore

PlasmaCore.SortFilterModel {
	id: appsDetector

	sourceModel: PlasmaCore.DataModel {
			dataSource: source
	}

	filterRole: "name"
	sortColumn: 0
	sortRole: "name"
	sortOrder: Qt.AscendingOrder

	// https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/core/datasource.h
	property var dataSource: PlasmaCore.DataSource {
			id: source
			engine: "apps"
			connectedSources: {
					// Explude folder
					var result = []
					for (var i = 0; i < sources.length; i++) {
							if (sources[i].indexOf(".desktop") !== -1) {
									result.push(sources[i])
							}
					}
					return result
			}
			interval: 0
	}
}
