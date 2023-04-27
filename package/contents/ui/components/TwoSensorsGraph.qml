import QtQuick 2.9
import QtGraphicalEffects 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.quickcharts 1.0 as Charts
import "./" as RMComponents

Item {
    id: chart

    signal dataTick
    signal showValueWhenMouseMove

    readonly property alias sensorsModel: sensorsModel
    property var sensors: []
    property var uplimits: [100, 100]

    property var _sensorData1
    property var _sensorData2

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

    // Text properties
    property bool secondLabelWhenZero: true

    // Bind properties
    onSensorsChanged: sensorsModel._updateSensors()

    onUplimitsChanged: {
        firstChart.yRange.to = uplimits[0];
        secondChart.yRange.to = uplimits[1];
    }

    onIntervalChanged: _clearHistory()

    // Graphs
    Charts.LineChart {
        id: secondChart
        anchors.fill: parent

        direction: Charts.XYChart.ZeroAtEnd
        fillOpacity: plasmoid.configuration.graphFillOpacity / 100
        smooth: true

        yRange {
            from: 0
            to: 100
            automatic: false
        }

        colorSource: Charts.SingleValueSource {
            value: colors[1]
        }
        valueSources: [
            Charts.HistoryProxySource {
                id: secondChartHistory

                source: Charts.SingleValueSource {
                    id: secondChartSource
                }
                interval: chart.visible ? chart.interval : 0
                maximumHistory: chart.interval > 0 ? (chart.historyAmount * 1000) / chart.interval : 0
                fillMode: Charts.HistoryProxySource.FillFromStart

                onDataChanged: _dataTick()
            }
        ]
    }
    Charts.LineChart {
        id: firstChart
        anchors.fill: parent

        direction: Charts.XYChart.ZeroAtEnd
        fillOpacity: plasmoid.configuration.graphFillOpacity / 100
        smooth: true

        yRange {
            from: 0
            to: 100
            automatic: false
        }

        colorSource: Charts.SingleValueSource {
            value: colors[0]
        }
        valueSources: [
            Charts.HistoryProxySource {
                id: firstChartHistory

                source: Charts.SingleValueSource {
                    id: firstChartSource
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
    Instantiator {
        id: sensorsModel
        active: chart.visible
        delegate: Sensors.Sensor {
            id: sensor
            sensorId: modelData
            updateRateLimit: chart.interval
        }

        function _updateSensors() {
            model = sensors;
            _clearHistory();
        }
        function getData(index) {
            var object = objectAt(index);
            if (!object) {
                return;
            }
            return {
                "value": object.value,
                "formattedValue": object.formattedValue,
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
                _updateData(0, undefined)
                _updateData(1, undefined)
            }
            return;
        }

        // Update values
        chart._sensorData1 = sensorsModel.getData(0)
        chart._sensorData2 = sensorsModel.getData(1)

        if (chart._sensorData1) {
            firstChartSource.value = chart._sensorData1.value
        }
        if (chart._sensorData2) {
            secondChartSource.value = chart._sensorData2.value
        }

        // Update labels
        if (textContainer.valueVisible) {
            _updateData(0, chart._sensorData1)
            _updateData(1, chart._sensorData2)
        }
    }

    // Utils functions
    function _updateData(index, data) {
        var value = data && data.value;

        // Update label
        if (index === 0) {
            // is first line
            if (typeof value === 'undefined') {
                firstLineLabel.text = '...';
                firstLineLabel.visible = true;
            } else {
                firstLineLabel.text = data.formattedValue;
                firstLineLabel.visible = true;
            }
        } else if (index === 1) {
            // is second line
            if (typeof value === 'undefined') {
                secondLineLabel.text = '...';
                secondLineLabel.visible = secondLabelWhenZero;
            } else {
                secondLineLabel.text = data.formattedValue;
                secondLineLabel.visible = data.value !== 0 || secondLabelWhenZero;
            }
        }
    }

    function _showValueInLabel() {
        // Show first line
        _updateData(0, chart._sensorData1)
        // Show second line
        _updateData(1, chart._sensorData2)
        chart.showValueWhenMouseMove();
    }

    function _clearHistory() {
        firstChartHistory.clear();
        secondChartHistory.clear();
    }
}
