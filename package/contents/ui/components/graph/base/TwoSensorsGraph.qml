import QtQuick 2.15
import org.kde.plasma.plasmoid 2.0
import org.kde.quickcharts 1.0 as Charts
import "./" as RMBaseGraph

RMBaseGraph.BaseSensorGraph {
    id: root

    property var uplimits: [100, 100]

    // Graph properties
    property var colors: [theme.highlightColor, theme.textColor]
    property bool enableHistory: plasmoid.configuration.historyAmount > 0
    property bool secondChartVisible: true

    // Bind properties changes
    onUplimitsChanged: {
        firstChart.yRange.to = uplimits[0];
        secondChart.yRange.to = uplimits[1];
        firstChart.yRange.automatic = uplimits[0] == 0;
        secondChart.yRange.automatic = uplimits[1] == 0;
    }

    // Graphs
    Charts.LineChart {
        id: secondChart
        anchors.fill: parent
        visible: enableHistory && secondChartVisible

        direction: Charts.XYChart.ZeroAtEnd
        fillOpacity: plasmoid.configuration.graphFillOpacity / 100
        smooth: true
        yRange.automatic: false

        colorSource: Charts.SingleValueSource {
            value: colors[1]
        }
        valueSources: [
            RMBaseGraph.ArrayDataSource {
                id: secondChartData
                maximumHistory: plasmoid.configuration.historyAmount
            }
        ]
    }
    Charts.LineChart {
        id: firstChart
        anchors.fill: parent
        visible: enableHistory && secondChartVisible

        direction: Charts.XYChart.ZeroAtEnd
        fillOpacity: plasmoid.configuration.graphFillOpacity / 100
        smooth: true
        yRange.automatic: false

        colorSource: Charts.SingleValueSource {
            value: colors[0]
        }
        valueSources: [
            RMBaseGraph.ArrayDataSource {
                id: firstChartData
                maximumHistory: plasmoid.configuration.historyAmount
            }
        ]
    }

    _clear: () => {
        firstChartData.clear();
        secondChartData.clear();
        for (let i = 0; i < sensorsModel.sensors.length; i++) {
            _updateData(i);
        }
    }
    _insertChartData: (column, value) => {
        if (column == 0) {
            firstChartData.insertValue(value);
            root.chartDataChanged(0);
        } else if (column == 1) {
            secondChartData.insertValue(value);
            root.chartDataChanged(1);
        }
    }
}
