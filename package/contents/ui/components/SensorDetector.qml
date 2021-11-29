import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

QtObject {
	id: sensorDetector

	// https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/core/datasource.h
	property var dataSource: PlasmaCore.DataSource {
		id: dataSource
		engine: "systemmonitor"

		connectedSources: []

		// Note: DataSource.sources is not always populated on Component.onCompleted,
		//       but sometimes it is...
		// Note: The SystemMonitor widgets scan for sensorNames using the
		//       onSourceAdded signal, however any sensor already connected by
		//       another DataSource instance, like in our SensorData instance,
		//       will not have onSourceAdded called for that sensor.
		onSourcesChanged: {
			// console.log('sensorDetector.dataSource.onSourcesChanged', dataSource.sources)
			sensorDetector.updateModel()

		}
		Component.onCompleted: {
			// console.log('sensorDetector.dataSource.sources', dataSource.sources)
			sensorDetector.updateModel()
		}
	}

	function updateModel() {
		privateModel.clear()
		for (var i = 0; i < dataSource.sources.length; i++) {
			var sourceName = dataSource.sources[i]
			privateModel.append({
				name: sourceName
			})
		}
		sensorDetector.model = privateModel
	}

	property var privateModel: ListModel {
		id: privateModel
	}

	property var model: []
}
