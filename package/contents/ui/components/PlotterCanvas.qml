// SRC: https://github.com/Zren/plasma-applet-sysmonitordash/blob/560a38af570ebfbc0b580812bbf4f4fc53ce2655/package/contents/ui/PlotterCanvas.qml
import QtQuick 2.0


// Based on KQuickAddons.Plotter
// https://github.com/KDE/kdeclarative/blob/master/src/qmlcontrols/kquickcontrolsaddons/plotter.h
// https://github.com/KDE/kdeclarative/blob/master/src/qmlcontrols/kquickcontrolsaddons/plotter.cpp
Canvas {
	id: plotter
	property var maxs: [0]
	property var mins: [0]
	property int sampleSize: 5
	property bool stacked: false
	property var autoRanges: [false]
	property var rangesMax: [100]
	property var rangesMin: [0]
	property color gridColor: theme.backgroundColor
	property int horizontalGridLineCount: 0
	property bool normalizeRequested: true
	property double fillOpacity: 0.25

	property var dataSets: []

	onPaint: {
		if (!context) {
			getContext("2d")
		}

		if (normalizeRequested) {
			normalizeData()
			normalizeRequested = false
		}

		context.clearRect(0, 0, width, height)

		var prevPath = [
			[0, height], // bottom left
			[width, height], // bottom right
		]

		for (var i = dataSets.length-1; i >= 0; i--) {
			var dataSet = dataSets[i]

			var autoRange = autoRanges[i] || false
			var adjustedMax = autoRange ? maxs[i] : (rangesMax[i] || 100)
			var adjustedMin = autoRange ? mins[i] : (rangesMin[i] || 0)
			var rangeY = adjustedMax - adjustedMin

			//--- Generate curPath
			var curPath = new Array(dataSet.normalizedValues.length)
			context.beginPath()
			for (var j = 0; j < dataSet.normalizedValues.length; j++) {
				var value = dataSet.normalizedValues[j]
				var x = dataSet.sampleSize >= 2 ? j/(dataSet.sampleSize-1) : 0
				var y = (value - adjustedMin) / (rangeY > 0 ? rangeY : 1)
				x = x * width
				y = y * height
				y = height - y
				curPath[j] = [x, y]

				// Navigate curPath
				context.lineTo(x, y)
			}

			// Reverse navigate prevPath
			for (var j = prevPath.length-1; j >= 0; j--) {
				var p = prevPath[j]
				context.lineTo(p[0], p[1])
			}

			// Close and fill
			context.closePath()
			context.fillStyle = Qt.rgba(dataSet.color.r, dataSet.color.g, dataSet.color.b, fillOpacity)
			// context.fillStyle = dataSet.color
			context.fill()

			//--- Stroke lines
			context.lineWidth = Math.floor(1 * units.devicePixelRatio)
		 	context.beginPath()
		 	for (var j = 0; j < curPath.length; j++) {
		 		var p = curPath[j]
		 		context.lineTo(p[0], p[1])
		 	}
		 	context.strokeStyle = dataSet.color
		 	context.stroke()

			prevPath = curPath
		}
	}

	function normalizeData() {
		var adjustedMax = Number.NEGATIVE_INFINITY
		var adjustedMin = Number.POSITIVE_INFINITY
		if (stacked) {
			var prevDataSet = null
			for (var i = dataSets.length-1; i >= 0; i--) {
				var dataSet = dataSets[i]
				if (prevDataSet) {
					dataSet.normalizedValues = new Array(dataSet.values.length)
					for (var j = 0; j < dataSet.values.length; j++) {
						var normalizedValue = dataSet.values[j] + prevDataSet.normalizedValues[j]
						dataSet.normalizedValues[j] = normalizedValue
						if (normalizedValue > adjustedMax) {
							adjustedMax = normalizedValue
						}
						if (normalizedValue < adjustedMin) {
							adjustedMin = normalizedValue
						}
					}
				} else {
					dataSet.normalizedValues = dataSet.values.slice()
					if (dataSet.max > adjustedMax) {
						adjustedMax = dataSet.max
					}
					if (dataSet.min > adjustedMin) {
						adjustedMin = dataSet.min
					}
				}
				prevDataSet = dataSet

				if (dataSet.max > maxs[i]) {
					max[i] = dataSet.max
				}
				if (dataSet.min > mins[i]) {
					min[i] = dataSet.min
				}
			}
		} else {
			for (var i = 0; i < dataSets.length; i++) {
				var dataSet = dataSets[i]
				dataSet.normalizedValues = dataSet.values.slice()
				if (dataSet.max > maxs[i]) {
					adjustedMax = maxs[i] = dataSet.max
				}
				if (dataSet.min < min[i]) {
					adjustedMin = mins[i] = dataSet.min
				}
			}
		}
	}

	function addSample(values) {
		for (var i = 0; i < dataSets.length; i++) {
			dataSets[i].addSample(values[i])
		}
		for (var i = 0; i < dataSets.length; i++) {
			maxs[i] = dataSets[i].max
			mins[i] = dataSets[i].min
		}
		normalizeRequested = true
	}

	function updateSampleSize() {
		for (var i = 0; i < dataSets.length; i++) {
			dataSets[i].setSampleSize(sampleSize)
		}
	}
	onSampleSizeChanged: {
		updateSampleSize()
	}

	onDataSetsChanged: {
		updateSampleSize()
	}
}
