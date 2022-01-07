import QtQuick 2.9
import QtGraphicalEffects 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.quickcharts 1.0 as Charts

import "./" as RMComponents

RMComponents.BaseSensorGraph {
    id: chart

    readonly property alias sensorsModel: sensorsModel

    property bool customFormatter: false
    property var lastRun: -1

    Sensors.SensorDataModel {
        id: sensorsModel
        updateRateLimit: chart.interval
        enabled: chart.visible

        function getData(column = 0, role = Sensors.SensorDataModel.FormattedValue) {
            if (!hasIndex(0, column)) {
                return undefined
            }

            if (customFormatter && role === Sensors.SensorDataModel.FormattedValue) {
                return formatLabel(data(index(0, column), Sensors.SensorDataModel.Value))
            }
            return data(index(0, column), role)
        }
    }

    Instantiator {
        model: sensorsModel.sensors
        delegate: Charts.HistoryProxySource {
            id: history

            source: Charts.ModelSource {
                model: sensorsModel
                column: index
                roleName: "Value"
            }

            interval: chart.visible ? chart.interval : 0
            maximumHistory: interval > 0 ? (chart.historyAmount * 1000) / interval : 0
            fillMode: Charts.HistoryProxySource.FillFromStart

            onDataChanged: {
                // Skip when value is not visible
                if (canSeeValue(index)) {
                    var value = sensorsModel.getData(index)

                    // Update albel
                    if (index === 0) { // is first line
                        if (typeof value === 'undefined') {
                            firstLineLabel.text = '...'
                        } else {
                            firstLineLabel.text = value
                        }
                    } else if (index === 1) { // is second line
                        if (typeof value === 'undefined') {
                            secondLineLabel.text = '...'
                            secondLineLabel.visible = secondLabelWhenZero
                        } else {
                            secondLineLabel.text = value
                            secondLineLabel.visible = sensorsModel.getData(index, Sensors.SensorDataModel.Value) !== 0
                                || secondLabelWhenZero
                        }
                    }
                }

                // Call data tick
                var now = Date.now()
                if (now - lastRun >= chart.interval) {
                    lastRun = now
                    chart.dataTick()
                }
            }

            property var connection: Connections {
                target: chart
                function onIntervalChanged() {
                    history.clear()
                }
            }
        }
        onObjectAdded: {
            chart.insertValueSource(index, object)
        }
        onObjectRemoved: {
            chart.removeValueSource(object)
        }
    }

    function _showValueInLabel() {
        // Show first line
        var data = sensorsModel.getData(0)
        if (typeof data !== "undefined") {
            firstLineLabel.text = data
        } else {
            firstLineLabel.text = '...'
        }

        // Show second line
        data = sensorsModel.getData(1)
        if (typeof data !== "undefined") {
            secondLineLabel.text = data
            secondLineLabel.visible = sensorsModel.getData(1, Sensors.SensorDataModel.Value) !== 0 || secondLabelWhenZero
        } else {
            secondLineLabel.text = '...'
            secondLineLabel.visible = secondLabelWhenZero
        }

        chart.showValueWhenMouseMove()
    }
}
