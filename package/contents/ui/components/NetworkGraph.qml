import QtQuick 2.9
import QtGraphicalEffects 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.quickcharts 1.0 as Charts
import "./" as RMComponents
import "./functions.js" as Functions

Item {
    id: chart

    signal dataTick
    signal showValueWhenMouseMove

    // Aliases
    readonly property alias textContainer: textContainer
    property alias label: textContainer.label
    property alias labelColor: textContainer.labelColor
    property alias secondLabel: textContainer.secondLabel
    property alias secondLabelColor: textContainer.secondLabelColor
    property alias thirdLabel: textContainer.thirdLabel
    property alias thirdLabelColor: textContainer.thirdLabelColor
    readonly property alias firstLineLabel: textContainer.firstLineLabel
    readonly property alias secondLineLabel: textContainer.secondLineLabel
    readonly property alias thirdLineLabel: textContainer.thirdLineLabel

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
    onIgnoredNetworkInterfacesChanged: sensorsModel._updateSensors()

    onNetworkReceivingTotalChanged: {
        downloadChart.yRange.to = networkReceivingTotal * dialect.multiplier;
    }
    onNetworkSendingTotalChanged: {
        uploadChart.yRange.to = networkSendingTotal * dialect.multiplier;
    }

    onIntervalChanged: _clearHistory()

    // Graphs
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

        colorSource: Charts.SingleValueSource {
            value: colors[1]
        }
        valueSources: [
            Charts.HistoryProxySource {
                id: uploadHistory

                source: Charts.SingleValueSource {
                    id: uploadSpeed
                }
                interval: chart.visible ? chart.interval : 0
                maximumHistory: chart.interval > 0 ? (chart.historyAmount * 1000) / chart.interval : 0
                fillMode: Charts.HistoryProxySource.FillFromStart

                onDataChanged: _dataTick()
            }
        ]
    }
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

        colorSource: Charts.SingleValueSource {
            value: colors[0]
        }
        valueSources: [
            Charts.HistoryProxySource {
                id: downloadHistory

                source: Charts.SingleValueSource {
                    id: downloadSpeed
                }
                interval: chart.visible ? chart.interval : 0
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
        onModelChanged: sensorsModel._updateSensors()
    }

    Instantiator {
        id: sensorsModel
        active: chart.visible
        delegate: Sensors.Sensor {
            id: sensor
            sensorId: modelData
            updateRateLimit: chart.interval
        }

        function _updateSensors() {
            if (!chart.visible || typeof networkInterfaces.model.count === "undefined") {
                return;
            }
            var sensors = [];
            for (var i = 0; i < networkInterfaces.model.count; i++) {
                var name = networkInterfaces.model.get(i).name;
                if (ignoredNetworkInterfaces.indexOf(name) === -1) {
                    sensors.push("network/" + name + "/download", "network/" + name + "/upload");
                }
            }
            model = sensors;
            _clearHistory();
        }
        function getData(index) {
            var object = objectAt(index);
            return {
                "value": object.value || 0,
                "sensorId": object.sensorId
            };
        }
    }
    onVisibleChanged: sensorsModel._updateSensors()

    function _dataTick() {
        var sensorsLength = sensorsModel.model.length;

        // Emit signal
        chart.dataTick();

        // Set default text when doesn't have sensors
        if (sensorsLength === 0) {
            if (textContainer.valueVisible) {
                _updateData(0, undefined);
                _updateData(1, undefined);
            }
            return;
        }

        // Calculate total download
        var data;
        var downloadValue = 0, uploadValue = 0;
        for (var i = 0; i < sensorsLength; i++) {
            data = sensorsModel.getData(i);
            if (data.sensorId.indexOf('/download') !== -1) {
                downloadValue += data.value;
            } else {
                uploadValue += data.value;
            }
        }

        // Fix dialect
        downloadValue *= dialect.KiBDiff;
        uploadValue *= dialect.KiBDiff;

        // Update values
        downloadSpeed.value = downloadValue;
        uploadSpeed.value = uploadValue;

        // Update labels
        if (textContainer.valueVisible) {
            _updateData(0, downloadValue);
            _updateData(1, uploadValue);
        }
    }

    // Utils functions
    function canSeeValue(column) {
        return textContainer.valueVisible;
    }

    function formatLabel(value) {
        return Functions.formatByteValue(value, dialect);
    }

    function _updateData(index, value) {
        // Update label
        if (index === 0) {
            // is first line
            if (typeof value === 'undefined') {
                firstLineLabel.text = '...';
                firstLineLabel.visible = true;
            } else {
                firstLineLabel.text = formatLabel(value);
                firstLineLabel.visible = true;
            }
        } else if (index === 1) {
            // is second line
            if (typeof value === 'undefined') {
                secondLineLabel.text = '...';
                secondLineLabel.visible = secondLabelWhenZero;
            } else {
                secondLineLabel.text = formatLabel(value);
                secondLineLabel.visible = value !== 0 || secondLabelWhenZero;
            }
        }
    }

    function _showValueInLabel() {
        // Show first line
        _updateData(0, downloadSpeed.value);
        // Show second line
        _updateData(1, uploadSpeed.value);
        chart.showValueWhenMouseMove();
    }

    function _clearHistory() {
        downloadHistory.clear();
        uploadHistory.clear();
    }
}
