import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

QtObject {
	id: detector

	// https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/core/datasource.h
	property var dataSource: PlasmaCore.DataSource {
		id: dataSource
		engine: "executable"
		connectedSources: []

		property var excludedInterface: /^(?!lo|bridge|usbus|bond)(.*)$/

		onNewData: {
			var interfaces = data["stdout"].trim().split('\n')

			for(var i = 0; i < interfaces.length; i++) {
				if (excludedInterface.test(interfaces[i])) {
					privateModel.append({
						name: interfaces[i]
					})
				}
			}
			detector.model = privateModel
			disconnectSource(sourceName) // cmd finished
		}

		Component.onCompleted: {
			connectSource("ip -o link show | awk -F': ' '{print $2}'")
		}
	}

	property var privateModel: ListModel {
		id: privateModel
	}

	property var model: []
}
