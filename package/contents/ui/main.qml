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
import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import "./components/graph" as RMGraph
import "./components/functions.js" as Functions

MouseArea {
    id: root

    readonly property bool vertical: plasmoid.formFactor === PlasmaCore.Types.Vertical

    // Settings properties
    property bool verticalLayout: plasmoid.configuration.verticalLayout
    property double fontScale: (plasmoid.configuration.fontScale / 100)
    property bool haveClickAction: plasmoid.configuration.clickActionCommand !== ""

    // Component properties
    property int itemMargin: plasmoid.configuration.graphMargin
    property double parentWidth: parent === null ? 0 : parent.width
    property double parentHeight: parent === null ? 0 : parent.height
    property double initWidth: vertical ? (verticalLayout ? parentWidth : (parentWidth - itemMargin) / 2) : (verticalLayout ? (parentHeight - itemMargin) / 2 : parentHeight)
    property double itemWidth: Functions.getCustomConfig("graphWidth", Math.round(initWidth * (verticalLayout ? 1 : 1.5)))
    property double itemHeight: Functions.getCustomConfig("graphHeight", Math.round(initWidth))
    property double fontPixelSize: Math.round(verticalLayout ? (itemHeight / 1.4 * fontScale) : (itemHeight * fontScale))

    Layout.preferredWidth: !verticalLayout ? (itemWidth * graphView.model.length + itemMargin * (graphView.model.length + 1)) : itemWidth
    Layout.preferredHeight: verticalLayout ? (itemHeight * graphView.model.length + itemMargin * (graphView.model.length + 1)) : itemHeight
    LayoutMirroring.enabled: !vertical && Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    // Click action
    //? NOTE: This is hacky way for replace "Kio.KRun" due to limitation of access to C++ in widget without deploying package
    //? This have a lot limitation due to cannot open applications with `kioclient exec`, `kstart --application` or `xdg-open`.
    PlasmaCore.DataSource {
        id: runner
        engine: "executable"
        connectedSources: []
        onNewData: disconnectSource(sourceName)
    }
    onClicked: {
        if (haveClickAction) {
            runner.connectSource(plasmoid.configuration.clickActionCommand);
        }
    }

    // Global update timer
    Timer {
        id: updateTask
        interval: plasmoid.configuration.updateInterval * 1000

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
    }

    // Main Layout
    ListView {
        id: graphView
        anchors.fill: parent
        spacing: itemMargin
        orientation: verticalLayout ? ListView.Vertical : ListView.Horizontal
        interactive: false

        model: plasmoid.configuration.graphOrders.filter(item => {
            if (item === "cpu") {
                return plasmoid.configuration.cpuUnit !== "none";
            } else if (item === "disks") {
                return plasmoid.configuration.showDiskMonitor;
            } else if (item === "gpu") {
                return plasmoid.configuration.showGpuMonitor;
            } else if (item === "memory") {
                return plasmoid.configuration.memoryUnit !== "none";
            } else if (item === "network") {
                return plasmoid.configuration.networkUnit !== "none";
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
            }
        }

        function getGraph(index) {
            const loaderItem = graphView.itemAtIndex(index);
            return loaderItem !== null ? loaderItem.item : null;
        }
    }

    function _graphIdToFilename(graphId) {
        const filename = (graphId.charAt(0).toUpperCase() + graphId.slice(1)) + "Graph";
        return "./components/graph/" + filename + ".qml";
    }
}
