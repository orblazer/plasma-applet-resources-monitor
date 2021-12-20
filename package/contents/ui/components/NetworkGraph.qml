import QtQuick 2.9
import QtGraphicalEffects 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.ksysguard.faces 1.0 as Faces
import org.kde.quickcharts 1.0 as Charts

import "./" as RMComponents
import "./functions.js" as Functions

RMComponents.BaseSensorGraph {
	id: chart

    property var ignoredNetworkInterfaces: plasmoid.configuration.ignoredNetworkInterfaces
    property var dialect: Functions.getNetworkDialectInfo(plasmoid.configuration.networkUnit)
    property double networkReceivingTotal: plasmoid.configuration.networkReceivingTotal
    property double networkSendingTotal: plasmoid.configuration.networkSendingTotal

    property var downloadSensors: []
    property var uploadSensors: []

    onIgnoredNetworkInterfacesChanged: sensorsModel.updateSensors()

    onNetworkReceivingTotalChanged: netGraph._updateMaxSpeed()
    onNetworkSendingTotalChanged: netGraph._updateMaxSpeed()

    yRange {
        from: 0
        to: 100000
    }

    // Graph data

    RMComponents.NetworkInterfaceDetector {
        id: networkInterfaces
        onModelChanged: sensorsModel.updateSensors()
    }

    Sensors.SensorDataModel {
        id: sensorsModel
        updateRateLimit: chart.interval

        property var downloadModel: ListModel {
            id: downloadModel
        }
        property var uploadModel: ListModel {
            id: uploadModel
        }

        function getData(column) {
            if (!hasIndex(0, column)) {
                return 0
            }
            return data(index(0, column), Sensors.SensorDataModel.Value)
        }

        function updateSensors() {
            downloadSensors = []
            uploadSensors = []
            for (var i = 0; i < networkInterfaces.model.count; i++) {
                var name = networkInterfaces.model.get(i).name

                if (ignoredNetworkInterfaces.indexOf(name) === -1) {
                    downloadSensors.push("network/" + name + "/download")
                    uploadSensors.push("network/" + name + "/upload")
                }
            }

            sensorsModel.sensors = downloadSensors.concat(uploadSensors)
        }
    }

    Timer {
        id: timer
        repeat: true
        running: chart.visible
        interval: chart.interval
        onTriggered: {
            chart.dataTick()

            // Calculate total download
            var value = 0
            for (var i = 0; i < downloadSensors.length; i++) {
                value += sensorsModel.getData(i)
            }
            value *= dialect.KiBDiff // Fix dialect
            downloadSpeed.value = value

            // Update label
            if (canSeeValue(0)) {
                firstLineLabel.text = formatLabel(value)
            }

            // Calculate total upload
            value = 0
            for (var i = 0; i < uploadSensors.length; i++) {
                value += sensorsModel.getData(downloadSensors.length + i)
            }
            value *= dialect.KiBDiff // Fix dialect
            uploadSpeed.value = value

            // Update label
            if (canSeeValue(1)) {
                secondLineLabel.text = formatLabel(value)
                secondLineLabel.visible = value !== 0 || secondLabelWhenZero
            }
        }
    }

    valueSources: [
        Charts.HistoryProxySource {
            id: downloadHistory

            source: Charts.SingleValueSource {
                id: downloadSpeed
            }
            maximumHistory: chart.interval > 0 ? (chart.historyAmount * 1000) / chart.interval : 0
            fillMode: Charts.HistoryProxySource.FillFromEnd
        },
        Charts.HistoryProxySource {
            id: uploadHistory

            source: Charts.SingleValueSource {
                id: uploadSpeed
            }
            maximumHistory: chart.interval > 0 ? (chart.historyAmount * 1000) / chart.interval : 0
            fillMode: Charts.HistoryProxySource.FillFromEnd
        }
    ]

    onIntervalChanged: {
        downloadHistory.clear()
        uploadHistory.clear()
    }

    // Utils functions
    customFormatter: true
    function formatLabel(value) {
        return Functions.formatByteValue(value, dialect)
    }

    firstLineLabel.visible: false
    secondLineLabel.visible: false
    function _showValueInLabel() {
         if (!sensorsModel.ready) {
            firstLineLabel.visible = secondLineLabel.visible = false
            return
        }

        // Show first line
        var data = downloadSpeed.value
        firstLineLabel.text = formatLabel(data)
        firstLineLabel.visible = true

        // Show second line
        data = uploadSpeed.value
        secondLineLabel.text = formatLabel(data)
        secondLineLabel.visible = data !== 0 || secondLabelWhenZero

        valueVisible = true
        chart.showValueWhenMouseMove()
    }

    function _updateMaxSpeed() {
        yRange.to = Math.max(networkReceivingTotal, networkSendingTotal) * dialect.multiplier
    }
}
