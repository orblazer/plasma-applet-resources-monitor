import QtQuick 2.9

import org.kde.quickcharts 1.0 as Charts

import "./" as RMComponents

Charts.LineChart {
	id: chart

    signal dataTick()
    signal showValueWhenMouseMove()

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

    // Text properties
    property bool secondLabelWhenZero: true

    // Graph content
    direction: Charts.XYChart.ZeroAtEnd
    colorSource: Charts.ArraySource { array: colors }
    fillOpacity: plasmoid.configuration.graphFillOpacity / 100
    smooth: true
    yRange.automatic: false

    // Labels
    RMComponents.GraphText {
        id: textContainer
        anchors.fill: parent

        onShowValueInLabel: _showValueInLabel()
    }

    function canSeeValue(column) {
        return textContainer.valueVisible
    }

    function _showValueInLabel() {
        chart.showValueWhenMouseMove()
    }
}
