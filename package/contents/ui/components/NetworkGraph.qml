import QtQuick 2.9
import QtGraphicalEffects 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.ksysguard.faces 1.0 as Faces
import org.kde.quickcharts 1.0 as Charts

import "./" as RMComponents
import "./functions.js" as Functions

Item {
	id: chart

    signal dataTick()
    signal showValueWhenMouseMove()

    property var downloadSensors: []
    property var uploadSensors: []

    // Aliases
    readonly property alias textContainer: textContainer
    property alias label: textContainer.label
    property alias labelColor: textContainer.labelColor
    property alias secondLabel: textContainer.secondLabel
    property alias secondLabelColor: textContainer.secondLabelColor
    readonly property alias firstLineLabel: textContainer.firstLineLabel
    readonly property alias secondLineLabel: textContainer.secondLineLabel

    // Graph properties
    readonly property int historyAmount: plasmoid.configuration.historyAmount
    readonly property int interval: plasmoid.configuration.updateInterval * 1000
    property var colors: [theme.highlightColor, theme.textColor]
    property var ignoredNetworkInterfaces: plasmoid.configuration.ignoredNetworkInterfaces
    property var dialect: Functions.getNetworkDialectInfo(plasmoid.configuration.networkUnit)
    property double networkReceivingTotal: plasmoid.configuration.networkReceivingTotal
    property double networkSendingTotal: plasmoid.configuration.networkSendingTotal

    // Text properties
    property bool secondLabelWhenZero: true

    // Bind properties
    onIgnoredNetworkInterfacesChanged: sensorsModel.updateSensors()

    onNetworkReceivingTotalChanged: {
        downloadChart.yRange.to = networkReceivingTotal * dialect.multiplier
    }
    onNetworkSendingTotalChanged: {
        uploadChart.yRange.to = networkSendingTotal * dialect.multiplier
    }

    onIntervalChanged: {
        downloadHistory.clear()
        uploadHistory.clear()
    }

    // Graphs
    Charts.LineChart {
        id: downloadChart
        anchors.fill: parent

        direction: Charts.XYChart.ZeroAtEnd
        fillOpacity: plasmoid.configuration.graphFillOpacity / 100
        smooth: true

        yRange {
            from: 0
            to: 100000
            automatic: false
        }

        colorSource: Charts.SingleValueSource { value: colors[0] }
        valueSources: [
            Charts.HistoryProxySource {
                id: downloadHistory

                source: Charts.SingleValueSource {
                    id: downloadSpeed
                }
                maximumHistory: chart.interval > 0 ? (chart.historyAmount * 1000) / chart.interval : 0
                fillMode: Charts.HistoryProxySource.FillFromStart
            }
        ]
    }
    Charts.LineChart {
        id: uploadChart
        anchors.fill: parent

        direction: Charts.XYChart.ZeroAtEnd
        fillOpacity: plasmoid.configuration.graphFillOpacity / 100
        smooth: true

        yRange {
            from: 0
            to: 100000
            automatic: false
        }

        colorSource: Charts.SingleValueSource { value: colors[1] }
        valueSources: [
            Charts.HistoryProxySource {
                id: uploadHistory

                source: Charts.SingleValueSource {
                    id: uploadSpeed
                }
                maximumHistory: chart.interval > 0 ? (chart.historyAmount * 1000) / chart.interval : 0
                fillMode: Charts.HistoryProxySource.FillFromStart
            }
        ]
    }

    // Labels
    RMComponents.GraphText {
        id: textContainer
        anchors.fill: parent

        onShowValueInLabel: _showValueInLabel()
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
            var value = data(index(0, column), Sensors.SensorDataModel.Value)
            if (typeof value === "undefined") {
                return 0
            }
            return value
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
        onTriggered: _dataTick()
    }
    Component.onCompleted: _dataTick()

    function _dataTick() {
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
            firstLineLabel.visible = true
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

    // Utils functions
    function canSeeValue(column) {
        return textContainer.valueVisible
    }

    function formatLabel(value) {
        return Functions.formatByteValue(value, dialect)
    }

    function _showValueInLabel() {
        // Show first line
        var data = downloadSpeed.value
        if (typeof data === 'number') {
            firstLineLabel.text = formatLabel(data)
            firstLineLabel.visible = true
        } else {
            firstLineLabel.visible = false
        }

        // Show second line
        data = uploadSpeed.value
        if (typeof data === 'number') {
            secondLineLabel.text = formatLabel(data)
            secondLineLabel.visible = data !== 0 || secondLabelWhenZero
        } else {
            secondLineLabel.visible = false
        }

        chart.showValueWhenMouseMove()
    }
}
