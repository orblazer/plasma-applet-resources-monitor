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

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    property var _maximumHistory: -1

    // Settings properties
    property bool verticalLayout: Plasmoid.configuration.verticalLayout
    property double fontScale: (Plasmoid.configuration.fontScale / 100)

    // Component properties
    property int itemMargin: Plasmoid.configuration.graphMargin
    property double parentWidth: parent === null ? 0 : parent.width
    property double parentHeight: parent === null ? 0 : parent.height
    property double initWidth: vertical ? (verticalLayout ? parentWidth : (parentWidth - itemMargin) / 2) : (verticalLayout ? (parentHeight - itemMargin) / 2 : parentHeight)
    property double itemWidth: Plasmoid.configuration.customGraphWidth ? Plasmoid.configuration.graphWidth : (initWidth * (verticalLayout ? 1 : 1.5))
    property double itemHeight: Plasmoid.configuration.customGraphHeight ? Plasmoid.configuration.graphHeight : initWidth
    property double fontPixelSize: verticalLayout ? (itemHeight / 1.4 * fontScale) : (itemHeight * fontScale)

    Layout.preferredWidth: !verticalLayout ? (itemWidth * graphView.model.length + itemMargin * (graphView.model.length + 1)) : itemWidth
    Layout.preferredHeight: verticalLayout ? (itemHeight * graphView.model.length + itemMargin * (graphView.model.length + 1)) : itemHeight
    LayoutMirroring.enabled: !vertical && Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    // Bind config change
    Connections {
        target: Plasmoid.configuration

        function onHistoryAmountChanged() {
            _updateMaximumHistory();
        }
    }
    Component.onCompleted: {
        _updateMaximumHistory();
    }

    // Click action
    Kio.KRun {
        id: kRun
    }

    onClicked: {
        kRun.openService(Plasmoid.configuration.actionService);
    }

    // Global update timer
    Timer {
        id: updateTask
        interval: Plasmoid.configuration.updateInterval * 1000

        running: true
        triggeredOnStart: true
        repeat: true

        onTriggered: {
            for (const i in graphView.model) {
                const graph = graphView.getGraph(i);
                if (graph !== null) {
                    graph._update();
                }
            }
        }
        onIntervalChanged: _updateMaximumHistory()
    }

    // Main Layout
    ListView {
        id: graphView
        anchors.fill: parent
        spacing: itemMargin
        orientation: verticalLayout ? ListView.Vertical : ListView.Horizontal
        interactive: false

        model: Plasmoid.configuration.graphOrders.filter(item => {
                if (item === "cpu") {
                    return Plasmoid.configuration.showCpuMonitor;
                } else if (item === "disks") {
                    return Plasmoid.configuration.showDiskMonitor;
                } else if (item === "gpu") {
                    return Plasmoid.configuration.showGpuMonitor;
                } else if (item === "memory") {
                    return Plasmoid.configuration.showRamMonitor;
                } else if (item === "network") {
                    return Plasmoid.configuration.showNetMonitor;
                }
                return false;
            })

        delegate: Loader {
            source: _graphIdToFilename(modelData)

            width: itemWidth
            height: itemHeight

            onLoaded: {
                item.textContainer.firstLineLabel.font.pixelSize = Qt.binding(() => root.fontPixelSize);
                item.textContainer.secondLineLabel.font.pixelSize = Qt.binding(() => root.fontPixelSize);
                item.textContainer.thirdLineLabel.font.pixelSize = Qt.binding(() => root.fontPixelSize);
                item._setMaximumHistory(_maximumHistory);
            }
        }

        function getGraph(index) {
            const loaderItem = graphView.itemAtIndex(index);
            return loaderItem !== null ? loaderItem.item : null;
        }
    }

    function _updateMaximumHistory() {
        _maximumHistory = updateTask.interval > 0 ? (Plasmoid.configuration.historyAmount * 1000) / updateTask.interval : 0;

        // Clear history and set new maximum history
        for (const i in graphView.model) {
            const graph = graphView.getGraph(i);
            if (graph !== null) {
                graph._clear();
                graph._setMaximumHistory(_maximumHistory);
            }
        }
    }

    function _graphIdToFilename(graphId) {
        const filename = (graphId.charAt(0).toUpperCase() + graphId.slice(1)) + "Graph";
        return "./components/graph/" + filename + ".qml";
    }
}
