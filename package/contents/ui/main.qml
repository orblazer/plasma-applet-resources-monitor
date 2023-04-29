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
import QtQuick 2.9
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kio 1.0 as Kio
import "./components/graph" as RMGraph

MouseArea {
    id: root

    readonly property bool vertical: plasmoid.formFactor === PlasmaCore.Types.Vertical
    property var _maximumHistory: -1

    // Settings properties
    property bool verticalLayout: plasmoid.configuration.verticalLayout
    property double fontScale: (plasmoid.configuration.fontScale / 100)

    property bool showCpuMonitor: plasmoid.configuration.showCpuMonitor
    property bool showRamMonitor: plasmoid.configuration.showRamMonitor
    property bool showGpuMonitor: plasmoid.configuration.showGpuMonitor
    property bool showDiskMonitor: plasmoid.configuration.showDiskMonitor
    property bool showNetMonitor: plasmoid.configuration.showNetMonitor

    // Apearance settings properties
    property int historyAmount: plasmoid.configuration.historyAmount

    // Component properties
    property int itemMargin: plasmoid.configuration.graphMargin
    property int monitorsCount: (showCpuMonitor & 1) + (showRamMonitor & 1) + (showGpuMonitor & 1) + (showDiskMonitor & 1) + (showNetMonitor & 1)
    property double parentWidth: parent === null ? 0 : parent.width
    property double parentHeight: parent === null ? 0 : parent.height
    property double initWidth: vertical ? (verticalLayout ? parentWidth : (parentWidth - itemMargin) / 2) : (verticalLayout ? (parentHeight - itemMargin) / 2 : parentHeight)
    property double itemWidth: plasmoid.configuration.customGraphWidth ? plasmoid.configuration.graphWidth : (initWidth * (verticalLayout ? 1 : 1.5))
    property double itemHeight: plasmoid.configuration.customGraphHeight ? plasmoid.configuration.graphHeight : initWidth
    property double fontPixelSize: verticalLayout ? (itemHeight / 1.4 * fontScale) : (itemHeight * fontScale)

    Layout.preferredWidth: !verticalLayout ? (itemWidth * monitorsCount + itemMargin * (monitorsCount + 1)) : itemWidth
    Layout.preferredHeight: verticalLayout ? (itemHeight * monitorsCount+ itemMargin * (monitorsCount + 1)) : itemHeight
    LayoutMirroring.enabled: !vertical && Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    // Bind config change
    onHistoryAmountChanged: {
        _calculateMaximumHistory();
        for (const i in graphView.children) {
            graphView.children[i]._setMaximumHistory(_maximumHistory);
        }
    }

    // Click action
    Kio.KRun {
        id: kRun
    }

    onClicked: {
        kRun.openService(plasmoid.configuration.actionService);
    }

    // Global update timer
    Timer {
        id: updateTask
        interval: plasmoid.configuration.updateInterval * 1000

        running: true
        triggeredOnStart: true
        repeat: true

        onTriggered: {
            for (const i in graphView.children) {
                graphView.children[i]._update();
            }
        }

        onIntervalChanged: {
            _calculateMaximumHistory();
            for (const i in graphView.children) {
                graphView.children[i]._clear();
                graphView.children[i]._setMaximumHistory(_maximumHistory);
            }
        }
    }

    // Main Layout
    Flow {
        id: graphView
        anchors.fill: parent
        spacing: itemMargin

        flow: vertical ? Flow.TopToBottom : Flow.LeftToRight

        RMGraph.CpuGraph {
            visible: showCpuMonitor

            width: itemWidth
            height: itemHeight

            textContainer {
                firstLineLabel.font.pixelSize: root.fontPixelSize
                secondLineLabel.font.pixelSize: root.fontPixelSize
                thirdLineLabel.font.pixelSize: root.fontPixelSize
            }
        }
        RMGraph.MemoryGraph {
            visible: showRamMonitor

            width: itemWidth
            height: itemHeight

            textContainer {
                firstLineLabel.font.pixelSize: root.fontPixelSize
                secondLineLabel.font.pixelSize: root.fontPixelSize
                thirdLineLabel.font.pixelSize: root.fontPixelSize
            }
        }
        RMGraph.GpuGraph {
            visible: showGpuMonitor

            width: itemWidth
            height: itemHeight

            textContainer {
                firstLineLabel.font.pixelSize: root.fontPixelSize
                secondLineLabel.font.pixelSize: root.fontPixelSize
                thirdLineLabel.font.pixelSize: root.fontPixelSize
            }
        }
        RMGraph.DisksGraph {
            visible: showDiskMonitor

            width: itemWidth
            height: itemHeight

            textContainer {
                firstLineLabel.font.pixelSize: root.fontPixelSize
                secondLineLabel.font.pixelSize: root.fontPixelSize
                thirdLineLabel.font.pixelSize: root.fontPixelSize
            }
        }
        RMGraph.NetworkGraph {
            visible: showNetMonitor

            width: itemWidth
            height: itemHeight

            textContainer {
                firstLineLabel.font.pixelSize: root.fontPixelSize
                secondLineLabel.font.pixelSize: root.fontPixelSize
                thirdLineLabel.font.pixelSize: root.fontPixelSize
            }
        }
    }

    function _calculateMaximumHistory() {
        _maximumHistory = updateTask.interval > 0 ? (historyAmount * 1000) / updateTask.interval : 0;
    }
}
