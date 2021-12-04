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

import "./components" as RMComponents
import "./components/functions.js" as Functions

Item {
    id: main

    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
    property color primaryColor: theme.highlightColor
    property color negativeColor: theme.negativeTextColor
    property color neutralColor: theme.neutralTextColor
    property color positiveColor: theme.positiveTextColor

    // Settings properties
    property bool verticalLayout: plasmoid.configuration.verticalLayout
    property int sampleCount: plasmoid.configuration.sampleCount
    property string actionService: plasmoid.configuration.actionService

    property bool showCpuMonitor: plasmoid.configuration.showCpuMonitor
    property bool showClock: plasmoid.configuration.showClock
    property bool showRamMonitor: plasmoid.configuration.showRamMonitor
    property bool showMemoryInPercent: plasmoid.configuration.memoryInPercent
    property bool showSwapGraph: plasmoid.configuration.memorySwapGraph
    property bool showNetMonitor: plasmoid.configuration.showNetMonitor
    property bool networkInKilobit: plasmoid.configuration.networkInKilobit
    property double fontScale: (plasmoid.configuration.fontScale / 100)
    property double graphFillOpacity: (plasmoid.configuration.graphFillOpacity / 100)

    // Colors settings properties
    property color cpuColor: plasmoid.configuration.customCpuColor ? plasmoid.configuration.cpuColor : primaryColor
    property color ramColor: plasmoid.configuration.customRamColor ? plasmoid.configuration.ramColor : primaryColor
    property color swapColor: plasmoid.configuration.customSwapColor ? plasmoid.configuration.swapColor : negativeColor
    property color netDownColor: plasmoid.configuration.customNetDownColor ? plasmoid.configuration.netDownColor : primaryColor
    property color netUpColor: plasmoid.configuration.customNetUpColor ? plasmoid.configuration.netUpColor : positiveColor

    // Component properties
    property int containerCount: (showCpuMonitor?1:0) + (showRamMonitor?1:0) + (showNetMonitor?1:0)
    property int itemMargin: plasmoid.configuration.graphMargin
    property double parentWidth: parent === null ? 0 : parent.width
    property double parentHeight: parent === null ? 0 : parent.height
    property double initWidth:  vertical ? ( verticalLayout ? parentWidth : (parentWidth - itemMargin) / 2 ) : ( verticalLayout ? (parentHeight - itemMargin) / 2 : parentHeight )
    property double itemWidth: plasmoid.configuration.customGraphWidth ? plasmoid.configuration.graphWidth : initWidth * 1.4
    property double itemHeight: plasmoid.configuration.customGraphHeight ? plasmoid.configuration.graphHeight : initWidth
    property double fontPixelSize: itemHeight * fontScale
    property double widgetWidth: !verticalLayout ? (itemWidth*containerCount + itemMargin*containerCount) : itemWidth
    property double widgetHeight: verticalLayout ? (itemHeight*containerCount + itemMargin*containerCount) : itemHeight

    Layout.preferredWidth:  widgetWidth
    Layout.maximumWidth: widgetWidth
    Layout.preferredHeight: widgetHeight
    Layout.maximumHeight: widgetHeight

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    anchors.fill: parent

    Kio.KRun {
        id: kRun
    }

    // Bind settigns change

    onGraphFillOpacityChanged: {
        for (var monitor of [cpuGraph, ramGraph, netGraph]) {
            monitor.fillOpacity = graphFillOpacity
        }
    }

    onFontPixelSizeChanged: {
        for (var monitor of [cpuGraph, ramGraph, netGraph]) {
            monitor.firstLineLabel.font.pixelSize = fontPixelSize
            monitor.secondLineLabel.font.pixelSize = fontPixelSize
        }
    }

    onShowClockChanged: {
        if (showClock) {
            sensorData.dataSource.connectSource(sensorData.sensors.averageClock)
        } else {
            cpuGraph.secondLineLabel.visible = false
            sensorData.dataSource.disconnectSource(sensorData.sensors.averageClock)
        }
    }
    onShowRamMonitorChanged: {
        if (showRamMonitor) {
            sensorData.dataSource.connectSource(sensorData.sensors.memFree)
            sensorData.dataSource.connectSource(sensorData.sensors.memUsed)
        } else {
            sensorData.dataSource.disconnectSource(sensorData.sensors.memFree)
            sensorData.dataSource.disconnectSource(sensorData.sensors.memUsed)
        }
    }

    // Graph data
    RMComponents.SensorData {
        id: sensorData
        dataSource.interval: 1000 * plasmoid.configuration.updateInterval
    }

    // Graphs
    RMComponents.SensorGraph {
        id: cpuGraph
        sampleSize: sampleCount
        sensors: [sensorData.sensors.totalLoad]
        colors: [cpuColor]
        defaultsMax: [100]

        visible: showCpuMonitor
        width: itemWidth
        height: itemHeight

        label: "CPU"
        labelColor: cpuColor
        secondLabel: showClock ? i18n("⏲ Clock") : ""

        Connections {
            property string units: sensorData.getUnits(sensorData.sensors.averageClock)
            target: sensorData
            enabled: showClock
            function onDataTick() {
                if (!sensorData.isConnectedSource(sensorData.sensors.averageClock)) {
					sensorData.connectSource(sensorData.sensors.averageClock)
				}

                // Update labels
                if (cpuGraph.valueVisible) {
                    cpuGraph.secondLineLabel.text = cpuGraph.secondLineLabel.lastValue = cpuGraph.formatLabel(
                        sensorData.getData(sensorData.sensors.averageClock), units)
                    cpuGraph.secondLineLabel.visible = true
                }
            }
        }
    }

    RMComponents.SensorGraph {
        id: ramGraph
        sampleSize: sampleCount
        sensors: [sensorData.sensors.memApplication, sensorData.sensors.swapUsed]
        colors: [ramColor, swapColor]

        visible: showRamMonitor
        width: itemWidth
        height: itemHeight
        anchors.left: parent.left
        anchors.leftMargin: showCpuMonitor && !verticalLayout ? itemWidth + itemMargin : 0
        anchors.top: parent.top
        anchors.topMargin: showCpuMonitor && verticalLayout ? itemWidth + itemMargin : 0

        label: "RAM"
        labelColor: cpuColor
        secondLabel: showSwapGraph ? "Swap" : ""
        secondLabelColor: swapColor
        secondLabelWhenZero: false

        function getDefaultsMax() {
            return [
                sensorData.hasData(sensorData.sensors.memUsed) && sensorData.hasData(sensorData.sensors.memFree)
                    ? sensorData.memTotal : false,
                sensorData.hasData(sensorData.sensors.swapUsed) && sensorData.hasData(sensorData.sensors.swapFree)
                    ? sensorData.swapTotal : false
            ]
        }

        function formatLabel(value, units) {
            if (showMemoryInPercent) {
                return Math.round(sensorData.memPercentage(value)) + "%"
            } else {
                return humanReadableBytes(value)
            }
        }
    }

    RMComponents.SensorGraph {
        id: netGraph
        sampleSize: sampleCount
        sensors: [sensorData.sensors.networkReceiver, sensorData.sensors.networkTransmitter]
        colors: [netDownColor, netUpColor]
        defaultsMax: [sensorData.networkReceivingTotal, sensorData.networkSendingTotal]

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

        function formatLabel(value, units) {
            if (networkInKilobit) {
                return Functions.humanReadableBits(value * 8192)
            } else {
                return humanReadableBytes(value) + '/s'
            }
        }
    }

    // Click action
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            kRun.openService(actionService)
        }
    }

    function humanReadableBytes(value) {
        if (isNaN(parseInt(value))) {
            value = 0
        }

		// https://github.com/KDE/kcoreaddons/blob/master/src/lib/util/kformat.h
		return KCoreAddons.Format.formatByteSize(value * 1024)
	}
}
