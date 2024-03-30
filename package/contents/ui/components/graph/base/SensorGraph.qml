import QtQuick
import org.kde.plasma.plasmoid
import org.kde.quickcharts as Charts

BaseSensorGraph {
    id: root

    // Aliases
    property alias chart: chart

    // Graph
    Charts.LineChart {
        id: chart
        anchors.fill: parent
        visible: Plasmoid.configuration.historyAmount > 0

        direction: Charts.XYChart.ZeroAtEnd
        fillOpacity: Plasmoid.configuration.graphFillOpacity / 100
        smooth: true
        yRange.to: 100
        yRange.automatic: false

        colorSource: Charts.SingleValueSource {
            value: textContainer._resolveColor(colors[0])
        }
        valueSources: [
            ArrayDataSource {
                id: chartData
                maximumHistory: Plasmoid.configuration.historyAmount
            }
        ]
    }

    _insertChartData: (column, value) => {
        if (column == 0) {
            chartData.insertValue(value);
        }
    }
}
