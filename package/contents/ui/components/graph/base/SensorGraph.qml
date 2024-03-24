import QtQuick
import org.kde.plasma.plasmoid
import org.kde.quickcharts as Charts
import org.kde.kirigami as Kirigami
import "./" as RMBaseGraph

RMBaseGraph.BaseSensorGraph {
    id: root

    // Aliases
    property alias chart: chart

    // Graph properties
    property color chartColor: Kirigami.Theme.highlightColor

    // Graph
    Charts.LineChart {
        id: chart
        anchors.fill: parent
        visible: Plasmoid.configuration.historyAmount > 0

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
                maximumHistory: Plasmoid.configuration.historyAmount
            }
        ]
    }

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
