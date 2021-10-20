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
    property bool memoryInPercent: plasmoid.configuration.memoryInPercent
    property bool showMemoryInPercent: memoryInPercent
    property bool memoryUseAllocated: plasmoid.configuration.memoryUseAllocated
    property bool showSwapGraph: plasmoid.configuration.memorySwapGraph
    property bool showNetMonitor: plasmoid.configuration.showNetMonitor
    property double fontScale: (plasmoid.configuration.fontScale / 100)
    property int downloadMaxKBs: plasmoid.configuration.downloadMaxKBs
    property int uploadMaxKBs: plasmoid.configuration.uploadMaxKBs

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

    onFontPixelSizeChanged: {
        for (var monitor of [cpuMonitor, ramMonitor, netMonitor]) {
            monitor.firstLineInfoLabel.font.pixelSize = fontPixelSize
            monitor.firstLineValueLabel.font.pixelSize = fontPixelSize
            monitor.secondLineInfoLabel.font.pixelSize = fontPixelSize
            monitor.secondLineValueLabel.font.pixelSize = fontPixelSize
        }
    }

    // Graph data

    PlasmaCore.DataSource {
        id: dataSource
        engine: "systemmonitor"

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
        property string networkInterface: "network/interfaces/" + plasmoid.configuration.networkSensorInterface + "/"
        property string downloadTotal: networkInterface + "receiver/data"
        property string uploadTotal: networkInterface + "transmitter/data"

        property double totalCpuLoad: .0
        property int averageCpuClock: 0
        property int ramUsedBytes: 0
        property double ramUsedProportion: 0
        property int swapUsedBytes: 0
        property double swapUsedProportion: 0
        property double downloadKBs: 0
        property double uploadKBs: 0
        property double downloadProportion: 0
        property double uploadProportion: 0

        connectedSources: [memFree, memUsed, memApplication, swapUsed, swapFree, averageClock, totalLoad, downloadTotal, uploadTotal ]

        onNewData: {
            if (data.value === undefined) {
                return
            }
            if (sourceName == memApplication) {
                ramUsedBytes = parseInt(data.value)
                ramUsedProportion = fitMemoryUsage(data.value)
            }
            else if (sourceName == swapUsed) {
                swapUsedBytes = parseInt(data.value)
                swapUsedProportion = fitSwapUsage(data.value)
            }
            else if (sourceName == totalLoad) {
                totalCpuLoad = data.value / 100
            }
            else if (sourceName == averageClock) {
                averageCpuClock = parseInt(data.value)
                allUsageProportionChanged()
            }
            else if (sourceName == downloadTotal) {
                downloadKBs = parseFloat(data.value)
                downloadProportion = fitDownloadRate(data.value)
            }
            else if (sourceName == uploadTotal) {
                uploadKBs = parseFloat(data.value)
                uploadProportion = fitUploadRate(data.value)
            }
        }
        interval: 1000 * plasmoid.configuration.updateInterval
    }

    function fitMemoryUsage(usage) {
        var memFree = dataSource.data[dataSource.memFree]
        var memUsed = dataSource.data[dataSource.memUsed]
        if (!memFree || !memUsed) {
            return 0
        }
        return (usage / (parseFloat(memFree.value) +
                         parseFloat(memUsed.value)))
    }

    function fitSwapUsage(usage) {
        var swapFree = dataSource.data[dataSource.swapFree]
        if (!swapFree) {
            return 0
        }
        return (usage / (parseFloat(usage) + parseFloat(swapFree.value)))
    }

    function fitDownloadRate(rate) {
        if (!downloadMaxKBs) {
            return 0
        }
        return (rate / downloadMaxKBs)
    }

    function fitUploadRate(rate) {
        if (!uploadMaxKBs) {
            return 0
        }
        return (rate / uploadMaxKBs)
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

    function allUsageProportionChanged() {
        if (showCpuMonitor) {
            var totalCpuProportion = dataSource.totalCpuLoad

            cpuMonitor.firstLineValueLabel.text = Math.round(totalCpuProportion * 100) + '%'
            cpuMonitor.firstLineValueLabel.color = totalCpuProportion > 0.9 ? warningColor : theme.textColor
            cpuMonitor.secondLineValueLabel.text = Functions.getHumanReadableClock(dataSource.averageCpuClock)

            Functions.addGraphData(cpuGraphModel, totalCpuProportion, graphGranularity)
        }

        if (showRamMonitor) {
            var totalRamProportion = dataSource.ramUsedProportion
            var totalSwapProportion = dataSource.swapUsedProportion

            Functions.addGraphData(ramGraphModel, totalRamProportion, graphGranularity)
            Functions.addGraphData(swapGraphModel, totalSwapProportion, graphGranularity)

            ramMonitor.firstLineValueLabel.text = showMemoryInPercent ? Math.round(totalRamProportion * 100) + '%'
                : Functions.getHumanReadableMemory(dataSource.ramUsedBytes)
            ramMonitor.firstLineValueLabel.color = totalRamProportion > 0.9 ? warningColor : theme.textColor
            ramMonitor.secondLineValueLabel.text = showMemoryInPercent ? Math.round(totalSwapProportion * 100) + '%'
                : Functions.getHumanReadableMemory(dataSource.swapUsedBytes)
            ramMonitor.secondLineValueLabel.color = totalSwapProportion > 0.9 ? warningColor : theme.textColor
            ramMonitor.secondLineValueLabel.visible = ramMonitor.secondLineValueLabel.enabled =
                !ramMonitor.secondLineInfoLabel.visible && totalSwapProportion > 0
        }

        if (showNetMonitor) {
            var totalDownloadProportion = dataSource.downloadProportion
            var totalUploadProportion = dataSource.uploadProportion

            Functions.addGraphData(uploadGraphModel, totalUploadProportion, graphGranularity)
            Functions.addGraphData(downloadGraphModel, totalDownloadProportion, graphGranularity)

            netMonitor.firstLineValueLabel.text = Functions.getHumanReadableNetRate(dataSource.downloadKBs)
            netMonitor.secondLineValueLabel.text = Functions.getHumanReadableNetRate(dataSource.uploadKBs)
        }
    }

    onShowClockChanged: {
        cpuMonitor.secondLineValueLabel.visible = showClock
    }

    onShowSwapGraphChanged: {
        ramMonitor.secondLineValueLabel.visible = showSwapGraph
    }

    onShowMemoryInPercentChanged: {
        allUsageProportionChanged()
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
