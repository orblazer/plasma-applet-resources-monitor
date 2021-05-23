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

    // Settings properties
    property bool verticalLayout: plasmoid.configuration.verticalLayout
    property bool showCpuMonitor: plasmoid.configuration.showCpuMonitor
    property bool showClock: plasmoid.configuration.showClock
    property bool showRamMonitor: plasmoid.configuration.showRamMonitor
    property bool memoryInPercent: plasmoid.configuration.memoryInPercent
    property bool showMemoryInPercent: memoryInPercent

    property color warningColor: theme.neutralTextColor
    property int graphGranularity: 20

    // Component properties
    property int itemMargin: 5
    property double parentWidth: parent === null ? 0 : parent.width
    property double parentHeight: parent === null ? 0 : parent.height
    property double itemWidth:  vertical ? ( verticalLayout ? parentWidth : (parentWidth - itemMargin) / 2 ) : ( verticalLayout ? (parentHeight - itemMargin) / 2 : parentHeight )
    property double itemHeight: itemWidth
    property double fontPixelSize: itemHeight * 0.26
    property double widgetWidth:  showCpuMonitor && showRamMonitor && !verticalLayout ? itemWidth*2 + itemMargin : itemWidth
    property double widgetHeight: showCpuMonitor && showRamMonitor &&  verticalLayout ? itemWidth*2 + itemMargin : itemWidth

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
        cpuMonitor.firstLineInfoLabel.font.pixelSize = fontPixelSize
        cpuMonitor.firstLineValueLabel.font.pixelSize = fontPixelSize
        cpuMonitor.secondLineInfoLabel.font.pixelSize = fontPixelSize
        cpuMonitor.secondLineValueLabel.font.pixelSize = fontPixelSize

        ramMonitor.firstLineInfoLabel.font.pixelSize = fontPixelSize
        ramMonitor.firstLineValueLabel.font.pixelSize = fontPixelSize
        ramMonitor.secondLineInfoLabel.font.pixelSize = fontPixelSize
        ramMonitor.secondLineValueLabel.font.pixelSize = fontPixelSize
    }

    // We need to get the full path to KSysguard to be able to run it
    PlasmaCore.DataSource {
        id: apps
        engine: 'apps'
        property string ksysguardSource: 'org.kde.ksysguard.desktop'
        connectedSources: [ ksysguardSource ]
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
        property string memApplication: memPhysical + "application"
        property string memUsed: memPhysical + "used"
        property string swap: "mem/swap/"
        property string swapUsed: swap + "used"
        property string swapFree: swap + "free"

        property double totalCpuLoad: .0
        property int averageCpuClock: 0
        property int ramUsedBytes: 0
        property double ramUsedProportion: 0
        property int swapUsedBytes: 0
        property double swapUsedProportion: 0

        connectedSources: [memFree, memUsed, memApplication, swapUsed, swapFree, averageClock, totalLoad ]

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

    ListModel {
        id: cpuGraphModel
    }

    ListModel {
        id: ramGraphModel
    }

    ListModel {
        id: swapGraphModel
    }

    function allUsageProportionChanged() {
        var totalCpuProportion = dataSource.totalCpuLoad
        var totalRamProportion = dataSource.ramUsedProportion
        var totalSwapProportion = dataSource.swapUsedProportion

        cpuMonitor.firstLineValueLabel.text = Math.round(totalCpuProportion * 100) + '%'
        cpuMonitor.firstLineValueLabel.color = totalCpuProportion > 0.9 ? warningColor : theme.textColor
        cpuMonitor.secondLineValueLabel.text = Functions.getHumanReadableClock(dataSource.averageCpuClock)

        ramMonitor.firstLineValueLabel.text = showMemoryInPercent ? Math.round(totalRamProportion * 100) + '%' : Functions.getHumanReadableMemory(dataSource.ramUsedBytes)
        ramMonitor.firstLineValueLabel.color = totalRamProportion > 0.9 ? warningColor : theme.textColor
        ramMonitor.secondLineValueLabel.text = showMemoryInPercent ? Math.round(totalSwapProportion * 100) + '%' : Functions.getHumanReadableMemory(dataSource.swapUsedBytes)
        ramMonitor.secondLineValueLabel.color = totalSwapProportion > 0.9 ? warningColor : theme.textColor
        ramMonitor.secondLineValueLabel.visible = !ramMonitor.secondLineInfoLabel.visible && totalSwapProportion > 0

        if (showCpuMonitor) {
            Functions.addGraphData(cpuGraphModel, totalCpuProportion, graphGranularity)
        }
        if (showRamMonitor) {
            Functions.addGraphData(ramGraphModel, totalRamProportion, graphGranularity)
            Functions.addGraphData(swapGraphModel, totalSwapProportion, graphGranularity)
        }
    }

    onShowClockChanged: {
        cpuMonitor.secondLineValueLabel.visible = showClock
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
        secondLineInfoText: showClock ? 'Clock' : ''
        firstGraphModel: cpuGraphModel
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
        secondLineInfoText: 'Swap'
        secondLineInfoTextColor: theme.negativeTextColor
        firstGraphModel: ramGraphModel
        secondGraphModel: swapGraphModel
        secondGraphBarColor: theme.negativeTextColor
    }

    // Click action
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            kRun.openUrl(apps.data[apps.ksysguardSource].entryPath)
        }
    }

}
