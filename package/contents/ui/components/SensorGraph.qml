import QtQuick 2.2
import QtGraphicalEffects 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

import "./" as RMComponents

Item {
	id: sensorGraph

    // Aliases
    property alias sampleSize: plotter.sampleSize
    property alias sensors: plotter.sensors
    property alias values: plotter.values
    property alias colors: plotter.colors
	property alias stacked: plotter.stacked
	property alias defaultsMax: plotter.defaultsMax
	property alias fillOpacity: plotter.fillOpacity
    property alias firstLineLabel: firstLineLabel
    property alias secondLineLabel: secondLineLabel

    // Text properties
    property color textColor: theme.textColor
    property string label: ''
    property color labelColor: theme.highlightColor
    property string secondLabel: ''
    property color secondLabelColor: theme.textColor
    property bool secondLabelWhenZero: true

    property bool enableShadows: plasmoid.configuration.enableShadows
    property string placement: plasmoid.configuration.placement // Values: top-right, top-left, bottom-right, bottom-left
    property string displayment: plasmoid.configuration.displayment // Values: always, hover, hover-hints

    property bool valueVisible: displayment !== 'hover' || !mouseArea.containsMouse

    // Graph properties
    readonly property string firstSensorUnits: sensorData.getUnits(sensors[0])
    readonly property string secondSensorUnits: sensors.length > 1 ? sensorData.getUnits(sensors[1]) : ""
    property var hideSensorIndexs: []

    RMComponents.PlotterCanvas {
        id: plotter
        anchors.fill: parent
        stacked: true

        property var sensors: []
        property var values: []

        property var colors: [theme.highlightColor]

        horizontalGridLineCount: 0

		property var defaultsMax: []
        property bool initialized: false

        function initialize() {
            if (initialized) {
                return
            }

            var _defaultsMax = (defaultsMax.length == 0 ? getDefaultsMax() : defaultsMax).slice(0)
            var _autoRanges = autoRanges.slice(0)
            var _rangesMin = rangesMin.slice(0)
            var _rangesMax = rangesMax.slice(0)

            // Generate autoRange, rangeMin and rangeMax
            var i, defaultMax, max
            for (i = 0; i < _defaultsMax.length; i++) {
                if (_defaultsMax[i] === false) {
                    return
                }

                defaultMax = _defaultsMax[i] || 0
                if (defaultMax == 0) {
                    _defaultsMax[i] = 0
                }
                max = maxs[i] || 0

                _autoRanges[i] = defaultMax == 0
                _rangesMin[i] = 0
                _rangesMax[i] = defaultMax > 0 ? Math.max(defaultMax, max) : max
            }

            // Update array
            defaultsMax = _defaultsMax
            autoRanges = _autoRanges
            rangesMin = _rangesMin
            rangesMax = _rangesMax

            initialized = true
        }

        // Data
        dataSets: []

		Component {
			id: plotDataComponent
			RMComponents.PlotData {}
		}
		onSensorsChanged: {
			var list = []
            var i, sensor
			for (i = 0; i < sensors.length; i++) {
                sensor = sensors[i]
				if (!sensor) {
					continue
				}
				if (!sensorData.isConnectedSource(sensor)) {
					sensorData.connectSource(sensor)
				}

                // Hide wanted graph
                if (hideSensorIndexs.indexOf(i) !== -1) {
                    continue
                }

                // Retrieve or create plotData
                if (dataSets[i] && dataSets[i].sensor === sensor) {
                    list.push(dataSets[i])
                } else {
                    var item = plotDataComponent.createObject(plotter, {
                        color: plotter.colors[i % plotter.colors.length],
                        sensor: sensor
                    })
                    list.push(item)
                }
			}
			dataSets = list
		}

        Connections {
			target: sensorData
			function onDataTick() {
                plotter.initialize()

                var values = new Array(plotter.sensors.length)
                var graphValues = new Array(plotter.sensors.length - hideSensorIndexs.length)
                for (var i = 0; i < plotter.sensors.length; i++) {
                    values[i] = sensorData.getData(plotter.sensors[i])

                    if (hideSensorIndexs.indexOf(i) === -1) {
                        graphValues[i] = values[i]
                    }
                }
                plotter.values = values
                plotter.addSample(graphValues)
				plotter.requestPaint()

                // Update labels
                if (valueVisible) {
                    firstLineLabel.text = formatLabel(values[0], sensorGraph.firstSensorUnits)
                    if (values.length > 1) {
                        secondLineLabel.text = formatLabel(values[1], sensorGraph.secondSensorUnits)
                        secondLineLabel.visible = canSeeSecondLine()
                    }
                }
			}
		}

        // Labels
        Column {
            id: textContainer
            width: parent.width
            state: placement

            // First line
            PlasmaComponents.Label {
                id: firstLineLabel
                width: parent.width
                height: contentHeight

                text: label
                color: labelColor

                font.pointSize: -1
            }
            PlasmaComponents.Label {
                id: secondLineLabel
                width: parent.width
                height: contentHeight
                property string lastValue: ''

                text: secondLabel
                color: secondLabelColor

                font.pointSize: -1
                visible: secondLabel != ''
            }

            // States
            states: [
                State {
                    name: 'top-left'
                    AnchorChanges {
                        target: textContainer
                        anchors.top: parent.top
                    }

                    PropertyChanges {
                        target: firstLineLabel
                        horizontalAlignment: Text.AlignLeft
                    }
                    PropertyChanges {
                        target: secondLineLabel
                        horizontalAlignment: Text.AlignLeft
                    }
                },
                State {
                    name: 'top-right'
                    AnchorChanges {
                        target: textContainer
                        anchors.top: parent.top
                    }

                    PropertyChanges {
                        target: firstLineLabel
                        horizontalAlignment: Text.AlignRight
                    }
                    PropertyChanges {
                        target: secondLineLabel
                        horizontalAlignment: Text.AlignRight
                    }
                },

                State {
                    name: 'bottom-left'
                    AnchorChanges {
                        target: textContainer
                        anchors.bottom: parent.bottom
                    }

                    PropertyChanges {
                        target: firstLineLabel
                        horizontalAlignment: Text.AlignLeft
                    }
                    PropertyChanges {
                        target: secondLineLabel
                        horizontalAlignment: Text.AlignLeft
                    }
                },
                State {
                    name: 'bottom-right'
                    AnchorChanges {
                        target: textContainer
                        anchors.bottom: parent.bottom
                    }

                    PropertyChanges {
                        target: firstLineLabel
                        horizontalAlignment: Text.AlignRight
                    }
                    PropertyChanges {
                        target: secondLineLabel
                        horizontalAlignment: Text.AlignRight
                    }
                }
            ]
        }

        DropShadow {
            visible: enableShadows
            anchors.fill: textContainer
            radius: 3
            samples: 8
            spread: 0.8
            fast: true
            color: theme.backgroundColor
            source: textContainer
        }
    }

    function canSeeSecondLine() {
        return parseInt(plotter.values[1]) !== 0 || secondLabelWhenZero
    }

    onDisplaymentChanged: {
        switch (displayment) {
            case 'always':
            case 'hover-hints':
                firstLineLabel.color = secondLineLabel.color = textColor

                firstLineLabel.text = formatLabel(plotter.values[0], sensorGraph.firstSensorUnits)
                firstLineLabel.visible = true
                if (plotter.values.length > 1) {
                    secondLineLabel.text = formatLabel(plotter.values[1], sensorGraph.secondSensorUnits)
                    secondLineLabel.visible = canSeeSecondLine()
                } else if (!secondLineLabel.keepVisible) {
                     secondLineLabel.text = ''
                     secondLineLabel.visible = false
                }

                valueVisible = true
                break

            case 'hover':
                firstLineLabel.visible = secondLineLabel.visible = false
                valueVisible = mouseArea.containsMouse
                break
        }
    }

    // Action
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: displayment !== 'always'

        onEntered: {
            switch (displayment) {
                case 'hover':
                    firstLineLabel.visible = true
                    secondLineLabel.visible = secondLineLabel.text != ''
                    break
                case 'hover-hints':
                    firstLineLabel.text = label
                    firstLineLabel.color = labelColor

                    secondLineLabel.text = secondLabel
                    secondLineLabel.color = secondLabelColor
                    secondLineLabel.visible = secondLineLabel.text != '' && secondLineLabel.enabled
                    break
            }
        }

        onExited: {
            switch (displayment) {
                case 'hover':
                    firstLineLabel.visible = secondLineLabel.visible = false
                    break
                case 'hover-hints':
                    firstLineLabel.color = secondLineLabel.color = textColor

                    firstLineLabel.text = formatLabel(plotter.values[0], sensorGraph.firstSensorUnits)
                    if (plotter.values.length > 1) {
                        secondLineLabel.text = formatLabel(plotter.values[1], sensorGraph.secondSensorUnits)
                        secondLineLabel.visible = canSeeSecondLine()
                    } else if (secondLineLabel.lastValue != 0 && secondLabelWhenZero) {
                        secondLineLabel.text = secondLineLabel.lastValue
                        secondLineLabel.visible = true
                    } else {
                        secondLineLabel.text = ''
                        secondLineLabel.visible = false
                    }
                    break
            }
        }
    }

    function getDefaultsMax() {
        return []
    }

    function formatLabel(value, units) {
        if (isNaN(value)) {
            return ''
        }

        if (units) {
            if (units == 'V') {
                return i18nc('%1 is data value, %2 is unit datatype', '%1 %2', Number(value).toFixed(2), units)
            } else {
                return i18nc('%1 is data value, %2 is unit datatype', '%1 %2', Math.round(value), units)
            }
        } else {
            return Math.round(value)
        }
    }
}
