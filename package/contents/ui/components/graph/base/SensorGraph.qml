import org.kde.plasma.plasmoid 2.0
import org.kde.quickcharts 1.0 as Charts
import "./" as RMBaseGraph

RMBaseGraph.BaseSensorGraph {
    id: root

    // Aliases
    property alias chart: chart

    // Graph properties
    property color chartColor: theme.highlightColor

    // Graph
    Charts.LineChart {
        id: chart
        anchors.fill: parent

        direction: Charts.XYChart.ZeroAtEnd
        fillOpacity: Plasmoid.configuration.graphFillOpacity / 100
        smooth: true
        yRange.automatic: false

        colorSource: Charts.SingleValueSource {
            value: chartColor
        }
        valueSources: [
            RMBaseGraph.ArrayDataSource {
                id: chartData
            }
        ]
    }

    property var _setMaximumHistory: (value) => chartData.maximumHistory = value
    _clear: () => {
        chartData.clear();
        for (let i = 0; i < sensorsModel.sensors.length; i++) {
            _updateData(i);
        }
    }
    _insertChartData: (column, value) => {
        if (column == 0) {
            chartData.insertValue(value);
            root.chartDataChanged(0);
        }
    }
}
