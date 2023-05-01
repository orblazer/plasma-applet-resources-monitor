import org.kde.plasma.plasmoid 2.0
import org.kde.quickcharts 1.0 as Charts
import "./" as RMBaseGraph

RMBaseGraph.BaseSensorGraph {
    id: root

    property var uplimits: [100, 100]

    // Graph properties
    property var colors: [theme.highlightColor, theme.textColor]

    // Bind properties changes
    onUplimitsChanged: {
        firstChart.yRange.to = uplimits[0];
        secondChart.yRange.to = uplimits[1];
    }

    // Graphs
    Charts.LineChart {
        id: secondChart
        anchors.fill: parent

        direction: Charts.XYChart.ZeroAtEnd
        fillOpacity: Plasmoid.configuration.graphFillOpacity / 100
        smooth: true
        yRange.automatic: false

        colorSource: Charts.SingleValueSource {
            value: colors[1]
        }
        valueSources: [
            RMBaseGraph.ArrayDataSource {
                id: secondChartData
            }
        ]
    }
    Charts.LineChart {
        id: firstChart
        anchors.fill: parent

        direction: Charts.XYChart.ZeroAtEnd
        fillOpacity: Plasmoid.configuration.graphFillOpacity / 100
        smooth: true
        yRange.automatic: false

        colorSource: Charts.SingleValueSource {
            value: colors[0]
        }
        valueSources: [
            RMBaseGraph.ArrayDataSource {
                id: firstChartData
            }
        ]
    }

    property var _setMaximumHistory: (value) => firstChartData.maximumHistory = secondChartData.maximumHistory = value
    _clear: () => {
        firstChartData.clear()
        secondChartData.clear()
        for (let i = 0; i < sensors.length; i++) {
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
