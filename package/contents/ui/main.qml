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
import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kio 1.0 as Kio

import "./components"
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

    property bool showCpuMonitor: plasmoid.configuration.showCpuMonitor
    property bool showClock: plasmoid.configuration.showClock
    property bool showRamMonitor: plasmoid.configuration.showRamMonitor
    property bool showMemoryInPercent: plasmoid.configuration.memoryInPercent
    property bool memoryUseAllocated: plasmoid.configuration.memoryUseAllocated
    property bool showSwapGraph: plasmoid.configuration.memorySwapGraph
    property bool showNetMonitor: plasmoid.configuration.showNetMonitor
    property double fontScale: (plasmoid.configuration.fontScale / 100)

    // Colors settings properties
    property color cpuColor: plasmoid.configuration.customCpuColor ? plasmoid.configuration.cpuColor : primaryColor
    property color ramColor: plasmoid.configuration.customRamColor ? plasmoid.configuration.ramColor : primaryColor
    property color swapColor: plasmoid.configuration.customSwapColor ? plasmoid.configuration.swapColor : negativeColor
    property color netDownColor: plasmoid.configuration.customNetDownColor ? plasmoid.configuration.netDownColor : primaryColor
    property color netUpColor: plasmoid.configuration.customNetUpColor ? plasmoid.configuration.netUpColor : positiveColor
    property color warningColor: plasmoid.configuration.customWarningColor ? plasmoid.configuration.warningColor : neutralColor

    property int graphGranularity: 20

    // Component properties
    property int containerCount: (showCpuMonitor?1:0) + (showRamMonitor?1:0) + (showNetMonitor?1:0)
    property int itemMargin: plasmoid.configuration.graphMargin
    property double parentWidth: parent === null ? 0 : parent.width
    property double parentHeight: parent === null ? 0 : parent.height
    property double initWidth:  vertical ? ( verticalLayout ? parentWidth : (parentWidth - itemMargin) / 2 ) : ( verticalLayout ? (parentHeight - itemMargin) / 2 : parentHeight )
    property double itemWidth: plasmoid.configuration.customGraphWidth ? plasmoid.configuration.graphWidth : initWidth
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

    onFontPixelSizeChanged: {
        for (var monitor of [cpuMonitor, ramMonitor, netMonitor]) {
            monitor.firstLineInfoLabel.font.pixelSize = fontPixelSize
            monitor.firstLineValueLabel.font.pixelSize = fontPixelSize
            monitor.secondLineInfoLabel.font.pixelSize = fontPixelSize
            monitor.secondLineValueLabel.font.pixelSize = fontPixelSize
        }
    }

    onShowCpuMonitorChanged: dataSourceChanged()
    onShowClockChanged: {
        dataSourceChanged()
        cpuMonitor.secondLineValueLabel.visible = showClock
    }
    onShowRamMonitorChanged: dataSourceChanged()
    onShowSwapGraphChanged: {
        dataSourceChanged()
        ramMonitor.secondLineValueLabel.visible = showSwapGraph
    }
    onShowNetMonitorChanged: dataSourceChanged()
    property var dataSourceChanged: Functions.rateLimit(function () {
        dataSource.sources.forEach(refreshSource)
    }, 1)

    // Graph data

    PlasmaCore.DataSource {
        id: dataSource
        engine: "systemmonitor"
        interval: 1000 * plasmoid.configuration.updateInterval

        property var networkRegex: /^network\/interfaces\/(?!lo|bridge|usbus|bond).*\/(transmitter|receiver)\/data$/

        property string cpuSystem: "cpu/system/"
        property string averageClock: cpuSystem + "AverageClock"
        property string totalLoad: cpuSystem + "TotalLoad"
        property string memPhysical: "mem/physical/"
        property string memFree: memPhysical + "free"
        property string memApplication: memPhysical + (memoryUseAllocated ? "allocated" : "application")
        property string memUsed: memPhysical + "used"
        property string swap: "mem/swap/"
        property string swapUsed: swap + "used"
        property string swapFree: swap + "free"
        property string downloadTotal: ""
        property string uploadTotal: ""

        onNewData: {
            if (data.value === undefined) {
                return
            }

            var value, fitedValue
            // CPU usage
            if (sourceName == totalLoad) {
                value = data.value / 100

                cpuMonitor.firstLineValueLabel.text = Math.round(value * 100) + '%'
                cpuMonitor.firstLineValueLabel.color = value > 0.9 ? warningColor : theme.textColor

                Functions.addGraphData(cpuGraphModel, value, graphGranularity)
            }
            // CPU clock
            else if (sourceName == averageClock) {
                value = parseInt(data.value)

                cpuMonitor.secondLineValueLabel.text = Functions.getHumanReadableClock(value)
            }
            // Memory usage
            else if (sourceName == memApplication) {
                value = parseInt(data.value)
                fitedValue = fitMemoryUsage(data.value)

                ramMonitor.firstLineValueLabel.text = showMemoryInPercent ? Math.round(fitedValue * 100) + '%'
                    : Functions.getHumanReadableMemory(value)
                ramMonitor.firstLineValueLabel.color = fitedValue > 0.9 ? warningColor : theme.textColor

                Functions.addGraphData(ramGraphModel, fitedValue, graphGranularity)
            }
            // Swap usage
            else if (sourceName == swapUsed) {
                value = parseInt(data.value)
                fitedValue = fitSwapUsage(data.value)

                ramMonitor.secondLineValueLabel.text = showMemoryInPercent ? Math.round(fitedValue * 100) + '%'
                    : Functions.getHumanReadableMemory(value)
                ramMonitor.secondLineValueLabel.color = fitedValue > 0.9 ? warningColor : theme.textColor
                ramMonitor.secondLineValueLabel.visible = ramMonitor.secondLineValueLabel.enabled =
                    !ramMonitor.secondLineInfoLabel.visible && fitedValue > 0

                Functions.addGraphData(swapGraphModel, fitedValue, graphGranularity)
            }
            // Net download
            else if (sourceName == downloadTotal) {
                value = parseFloat(data.value)
                fitedValue = Functions.getPercentUsage(data.value, plasmoid.configuration.downloadMaxKBs)

                netMonitor.firstLineValueLabel.text = Functions.getHumanReadableNetRate(value)

                Functions.addGraphData(downloadGraphModel, fitedValue, graphGranularity)
            }
            // Net upload
            else if (sourceName == uploadTotal) {
                value = parseFloat(data.value)
                fitedValue = Functions.getPercentUsage(data.value, plasmoid.configuration.uploadMaxKBs)

                netMonitor.secondLineValueLabel.text = Functions.getHumanReadableNetRate(value)

                Functions.addGraphData(uploadGraphModel, fitedValue, graphGranularity)
            }
        }
        onSourceAdded: {
            refreshSource(source)
        }
    }

    function refreshSource(source) {
        var needConnect = false

        if (source === dataSource.totalLoad) {
            needConnect = showCpuMonitor
        }
        else if (source === dataSource.averageClock) {
            needConnect = showClock
        }
        else if (source === dataSource.memFree || source === dataSource.memUsed || source === dataSource.memApplication) {
            needConnect = showRamMonitor
        }
        else if (source === dataSource.swapUsed || source === dataSource.swapFree) {
            needConnect = showSwapGraph
        }
        else if (dataSource.networkRegex.test(source)) {
            // Match network sources
            var match
            if (plasmoid.configuration.networkSensorInterface === '') {
                match = source.match(dataSource.networkRegex)
            } else {
                match = source.match(new RegExp('/^network\/interfaces\/' +
                    plasmoid.configuration.networkSensorInterface.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') +
                    '\/(transmitter|receiver)\/data$/'))
            }

            if (match != null) {
                if (match[1] === 'receiver') {
                    dataSource.downloadTotal = source
                } else {
                    dataSource.uploadTotal = source
                }
                needConnect = showNetMonitor
            }
        } else {
            return
        }

        if (needConnect) {
            dataSource.connectSource(source)
        } else {
            dataSource.disconnectSource(source)
        }
    }

    function fitMemoryUsage(usage) {
        var memFree = dataSource.data[dataSource.memFree]
        var memUsed = dataSource.data[dataSource.memUsed]
        if (!memFree || !memUsed) {
            return 0
        }
        return Functions.getPercentUsage(usage, parseFloat(memFree.value) + parseFloat(memUsed.value))
    }

    function fitSwapUsage(usage) {
        var swapFree = dataSource.data[dataSource.swapFree]
        if (!swapFree) {
            return 0
        }
        return Functions.getPercentUsage(usage, parseFloat(usage) + parseFloat(swapFree.value))
    }

    ListModel {
        id: cpuGraphModel
    }

    ListModel {
        id: ramGraphModel
    }

    ListModel {
        id: swapGraphModel
    }

    ListModel {
        id: uploadGraphModel
    }

    ListModel {
        id: downloadGraphModel
    }

    // Components
    GraphItem {
        id: cpuMonitor
        width: itemWidth
        height: itemHeight

        visible: showCpuMonitor
        firstLineInfoText: 'CPU'
        firstLineInfoTextColor: cpuColor
        secondLineInfoText: showClock ? 'Clock' : ''
        firstGraphModel: cpuGraphModel
        firstGraphBarColor: cpuColor
    }

    GraphItem {
        id: ramMonitor
        width: itemWidth
        height: itemHeight
        anchors.left: parent.left
        anchors.leftMargin: showCpuMonitor && !verticalLayout ? itemWidth + itemMargin : 0
        anchors.top: parent.top
        anchors.topMargin: showCpuMonitor && verticalLayout ? itemWidth + itemMargin : 0

        visible: showRamMonitor
        firstLineInfoText: 'RAM'
        firstLineInfoTextColor: ramColor
        secondLineInfoText: showSwapGraph ? 'Swap' : ''
        secondLineInfoTextColor: swapColor
        firstGraphModel: ramGraphModel
        firstGraphBarColor: ramColor
        secondGraphModel: swapGraphModel
        secondGraphBarColor: swapColor
    }

    GraphItem {
        id: netMonitor
        width: itemWidth
        height: itemHeight
        anchors.left: parent.left
        anchors.leftMargin: (showCpuMonitor && !verticalLayout ? itemWidth + itemMargin: 0) + (showRamMonitor && !verticalLayout ? itemWidth + itemMargin : 0)
        anchors.top: parent.top
        anchors.topMargin: (showCpuMonitor && verticalLayout ? itemWidth + itemMargin: 0) + (showRamMonitor && verticalLayout ? itemWidth + itemMargin : 0)

        visible: showNetMonitor
        firstLineInfoText: 'Down'
        firstLineInfoTextColor: netDownColor
        secondLineInfoText: 'Up'
        secondLineInfoTextColor: netUpColor
        firstGraphModel: downloadGraphModel
        firstGraphBarColor: netDownColor
        secondGraphModel: uploadGraphModel
        secondGraphBarColor: netUpColor
    }

    // Click action
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            kRun.openService("org.kde.ksysguard")
        }
    }

}
