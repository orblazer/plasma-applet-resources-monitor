// SRC: https://github.com/Zren/plasma-applet-sysmonitordash/blob/560a38af570ebfbc0b580812bbf4f4fc53ce2655/package/contents/ui/PlotDataObj.qml
import QtQuick 2.0

// Based on KQuickAddons.PlotData
// https://github.com/KDE/kdeclarative/blob/master/src/qmlcontrols/kquickcontrolsaddons/plotter.h
// https://github.com/KDE/kdeclarative/blob/master/src/qmlcontrols/kquickcontrolsaddons/plotter.cpp
QtObject {
	id: plotData

	property string label: ''
	property color color: '#000'
	property string sensor: ''
	property var values: []
	property real max: 0
	property real min: 0

	property int sampleSize: 0
	property var normalizedValues: []

	function addSample(value) {
		if (values.length >= sampleSize) {
			values.shift()
		}

		values.push(Number(value))

		max = Math.max.apply(null, values)
		min = Math.min.apply(null, values)

		valuesChanged()
	}

	function setSampleSize(size) {
		if (sampleSize == size) {
			return
		}

		if (values.length > size) {
			var numberToRemove = values.length - size
			for (var i = 0; i < numberToRemove; i++) {
				values.shift()
			}
		} else if (values.length < size) {
			var numberToAdd = size - values.length
			for (var i = 0; i < numberToAdd; i++) {
				values.unshift(0)
			}
		}

		sampleSize = size
	}
}
