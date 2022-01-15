/*
 * Copyright 2015  Martin Kotelnik <clearmartin@seznam.cz>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick 2.7
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kio 1.0 as Kio
import org.kde.kcoreaddons 1.0 as KCoreAddons

import org.kde.ksysguard.sensors 1.0 as Sensors

import "./components" as RMComponents

Item {
    id: main

    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
    property color primaryColor: theme.highlightColor
    property color negativeColor: theme.negativeTextColor

    // Settings properties
    property bool verticalLayout: plasmoid.configuration.verticalLayout
    property string actionService: plasmoid.configuration.actionService

    property bool showCpuMonitor: plasmoid.configuration.showCpuMonitor
    property bool showClock: plasmoid.configuration.showClock
    property bool showRamMonitor: plasmoid.configuration.showRamMonitor
    property bool showMemoryInPercent: plasmoid.configuration.memoryInPercent
    property bool showSwapGraph: plasmoid.configuration.memorySwapGraph
    property bool showNetMonitor: plasmoid.configuration.showNetMonitor
    property double fontScale: (plasmoid.configuration.fontScale / 100)

    // Colors settings properties
    property color cpuColor: plasmoid.configuration.customCpuColor ? plasmoid.configuration.cpuColor : primaryColor
    property color ramColor: plasmoid.configuration.customRamColor ? plasmoid.configuration.ramColor : primaryColor
    property color swapColor: plasmoid.configuration.customSwapColor ? plasmoid.configuration.swapColor : negativeColor
    property color netDownColor: plasmoid.configuration.customNetDownColor ? plasmoid.configuration.netDownColor : primaryColor
    property color netUpColor: plasmoid.configuration.customNetUpColor ? plasmoid.configuration.netUpColor : negativeColor

    // Component properties
    property int containerCount: (showCpuMonitor?1:0) + (showRamMonitor?1:0) + (showNetMonitor?1:0)
    property int itemMargin: plasmoid.configuration.graphMargin
    property double parentWidth: parent === null ? 0 : parent.width
    property double parentHeight: parent === null ? 0 : parent.height
    property double initWidth:  vertical ? (verticalLayout ? parentWidth : (parentWidth - itemMargin) / 2) : (verticalLayout ? (parentHeight - itemMargin) / 2 : parentHeight)
    property double itemWidth: plasmoid.configuration.customGraphWidth ? plasmoid.configuration.graphWidth : (initWidth * (verticalLayout ? 1 : 1.5))
    property double itemHeight: plasmoid.configuration.customGraphHeight ? plasmoid.configuration.graphHeight : initWidth
    property double fontPixelSize: verticalLayout ? (itemHeight / 1.4 * fontScale) : (itemHeight * fontScale)
    property double widgetWidth: !verticalLayout ? (itemWidth*containerCount + itemMargin*containerCount) : itemWidth
    property double widgetHeight: verticalLayout ? (itemHeight*containerCount + itemMargin*containerCount) : itemHeight

    Layout.preferredWidth: widgetWidth
    Layout.maximumWidth: widgetWidth
    Layout.preferredHeight: widgetHeight
    Layout.maximumHeight: widgetHeight

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    anchors.fill: parent

    Kio.KRun {
        id: kRun
    }

    // Bind settigns change
    onFontPixelSizeChanged: {
        for (var monitor of [cpuGraph, ramGraph, netGraph]) {
            monitor.firstLineLabel.font.pixelSize = fontPixelSize
            monitor.secondLineLabel.font.pixelSize = fontPixelSize
        }
    }

    onShowClockChanged: {
        if (!showClock) {
            cpuGraph.secondLineLabel.visible = false
        }
    }

    onShowMemoryInPercentChanged: {
        if (ramGraph.maxMemory == 0) {
            return
        }

        if (showMemoryInPercent) {
            ramGraph.yRange.to = 100
        } else {
            ramGraph.yRange.to = ramGraph.maxMemory
        }
        ramGraph.updateSensors()
    }

    onShowSwapGraphChanged: {
        if (ramGraph.maxMemory != 0) {
            ramGraph.updateSensors()
        }
    }

    // Graphs
    RMComponents.SensorGraph {
        id: cpuGraph
        sensors: ["cpu/all/usage"]
        colors: [cpuColor]

        visible: showCpuMonitor
        width: itemWidth
        height: itemHeight

        label: "CPU"
        labelColor: cpuColor
        secondLabel: showClock ? i18n("⏲ Clock") : ""

        yRange {
            from: 0
            to: 100
        }

        // Display first core frequency
        onDataTick: {
            if (canSeeValue(1)) {
                secondLineLabel.text = cpuFrequencySensor.formattedValue
                secondLineLabel.visible = true
            }
        }
        Sensors.Sensor {
            id: cpuFrequencySensor
            enabled: showClock
            sensorId: "cpu/cpu0/frequency"
        }
        onShowValueWhenMouseMove: {
            secondLineLabel.text = cpuFrequencySensor.formattedValue
            secondLineLabel.visible = true
        }

        function canSeeValue(column) {
            if (column === 1 && !showClock) {
                return false
            }

            return textContainer.valueVisible
        }
    }

    RMComponents.SensorGraph {
        id: ramGraph
        colors: [ramColor, swapColor]
        secondLabelWhenZero: false
        // TODO: stack the graph values for real fill percent ?

        yRange {
            from: 0
            to: 100
        }

        visible: showRamMonitor
        width: itemWidth
        height: itemHeight
        anchors.left: parent.left
        anchors.leftMargin: showCpuMonitor && !verticalLayout ? itemWidth + itemMargin : 0
        anchors.top: parent.top
        anchors.topMargin: showCpuMonitor && verticalLayout ? itemWidth + itemMargin : 0

        label: "RAM"
        labelColor: ramColor
        secondLabel: showSwapGraph ? "Swap" : ""
        secondLabelColor: swapColor

        // Get max y of graph
        property var maxMemory: 0
        Sensors.SensorDataModel {
            id: totalSensorsModel
            sensors: ["memory/physical/total", "memory/swap/total"]
            enabled: true

            property var totalMemory: -1
            property var totalSwap: -1
            onDataChanged: {
                if(topLeft.column === 0) {
                    totalMemory = parseInt(data(topLeft, Sensors.SensorDataModel.Value))
                }
                else if (topLeft.column === 1) {
                    totalSwap = parseInt(data(topLeft, Sensors.SensorDataModel.Value))
                }

                if ((!isNaN(totalMemory) && totalMemory !== -1) && (!isNaN(totalSwap) && totalSwap !== -1)) {
                    enabled = false

                    ramGraph.maxMemory = Math.max(totalMemory, totalSwap)
                    if (!showMemoryInPercent) {
                        ramGraph.yRange.to = ramGraph.maxMemory
                    }
                    ramGraph.updateSensors()
                }
            }
        }

        // Set the color of Swap
        onShowValueWhenMouseMove: {
            secondLineLabel.color = swapColor
        }

        function updateSensors() {
            var suffix = showMemoryInPercent ? "Percent" : ""

            if (showSwapGraph) {
                sensors = ["memory/physical/used" + suffix, "memory/swap/used" + suffix]
            } else {
                sensors = ["memory/physical/used" + suffix]
            }
        }
    }

    RMComponents.NetworkGraph {
        id: netGraph

        colors: [netDownColor, netUpColor]

        visible: showNetMonitor
        width: itemWidth
        height: itemHeight
        anchors.left: parent.left
        anchors.leftMargin: (showCpuMonitor && !verticalLayout ? itemWidth + itemMargin: 0) + (showRamMonitor && !verticalLayout ? itemWidth + itemMargin : 0)
        anchors.top: parent.top
        anchors.topMargin: (showCpuMonitor && verticalLayout ? itemWidth + itemMargin: 0) + (showRamMonitor && verticalLayout ? itemWidth + itemMargin : 0)

        label: i18n("⇘ Down")
        labelColor: netDownColor
        secondLabel: i18n("⇗ Up")
        secondLabelColor: netUpColor
    }

    // Click action
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            kRun.openService(actionService)
        }
    }
}
