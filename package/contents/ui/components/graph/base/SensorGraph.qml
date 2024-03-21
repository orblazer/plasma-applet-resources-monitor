import QtQuick 2.9
import org.kde.plasma.plasmoid 2.0
import org.kde.quickcharts 1.0 as Charts
import "./" as RMBaseGraph

RMBaseGraph.BaseSensorGraph {
    id: root

    // Aliases
    property alias chart: chart

    // Graph properties
    property color chartColor: theme.highlightColor

    Connections {
        target: plasmoid.configuration
        function onEnableHistoryChanged() {
            if (plasmoid.configuration.enableHistory) {
                chartData.clear();
            }
        }
    }

    // Graph
    Charts.LineChart {
        id: chart
        anchors.fill: parent
        visible: plasmoid.configuration.enableHistory

        direction: Charts.XYChart.ZeroAtEnd
        fillOpacity: plasmoid.configuration.graphFillOpacity / 100
        smooth: true
        yRange.automatic: false

        colorSource: Charts.SingleValueSource {
            value: chartColor
        }
        valueSources: [
            RMBaseGraph.ArrayDataSource {
                id: chartData
                maximumHistory: plasmoid.configuration.historyAmount
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
            if (plasmoid.configuration.enableHistory) {
                chartData.insertValue(value);
            }
            root.chartDataChanged(0);
        }
    }
}
