import QtQuick
import org.kde.plasma.plasmoid
import org.kde.quickcharts as Charts

BaseSensorGraph {
    id: root

    // Graph properties
    property bool enableHistory: Plasmoid.configuration.historyAmount > 0
    property bool secondChartVisible: true
    property var uplimits: [] // ONLY USED FOR CONFIG!
    property var realUplimits: [100, 100]

    // Bind properties changes
    onRealUplimitsChanged: {
        firstChart.yRange.to = realUplimits[0];
        secondChart.yRange.to = realUplimits[1];
        firstChart.yRange.automatic = realUplimits[0] == 0;
        secondChart.yRange.automatic = realUplimits[1] == 0;
    }

    // Graphs
    Charts.LineChart {
        id: secondChart
        anchors.fill: parent
        visible: enableHistory && secondChartVisible

        direction: Charts.XYChart.ZeroAtEnd
        fillOpacity: Plasmoid.configuration.graphFillOpacity / 100
        smooth: true
        yRange.automatic: false

        colorSource: Charts.SingleValueSource {
            value: textContainer._resolveColor(colors[1])
        }
        valueSources: [
            ArrayDataSource {
                id: secondChartData
                maximumHistory: Plasmoid.configuration.historyAmount
            }
        ]
    }
    Charts.LineChart {
        id: firstChart
        anchors.fill: parent
        visible: enableHistory

        direction: Charts.XYChart.ZeroAtEnd
        fillOpacity: Plasmoid.configuration.graphFillOpacity / 100
        smooth: true
        yRange.automatic: false

        colorSource: Charts.SingleValueSource {
            value: textContainer._resolveColor(colors[0])
        }
        valueSources: [
            ArrayDataSource {
                id: firstChartData
                maximumHistory: Plasmoid.configuration.historyAmount
            }
        ]
    }

    _insertChartData: (column, value) => {
        if (column == 0) {
            firstChartData.insertValue(value);
        } else if (column == 1) {
            secondChartData.insertValue(value);
        }
    }
}
