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
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami
import "./components/functions.mjs" as Functions
import "./components/graph" as RMGraph

PlasmoidItem {
    id: root

    readonly property int graphVersion: 1 //? Bump when some settings changes in "graphs" structure
    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    // Settings properties
    property bool verticalLayout: Plasmoid.configuration.verticalLayout
    property double fontScale: (Plasmoid.configuration.fontScale / 100)

    // Component properties
    property int itemMargin: Plasmoid.configuration.graphMargin
    property double parentWidth: parent === null ? 0 : parent.width
    property double parentHeight: parent === null ? 0 : parent.height
    property double initWidth: vertical ? (verticalLayout ? parentWidth : (parentWidth - itemMargin) / 2) : (verticalLayout ? (parentHeight - itemMargin) / 2 : parentHeight)
    property double itemWidth: _getCustomConfig("graphWidth", Math.round(initWidth * (verticalLayout ? 1 : 1.5)))
    property double itemHeight: _getCustomConfig("graphHeight", Math.round(initWidth))
    property double fontPixelSize: Math.round(verticalLayout ? (itemHeight / 1.4 * fontScale) : (itemHeight * fontScale))
    property var graphsModel: (JSON.parse(Plasmoid.configuration.graphs) || []).filter(v => v._v === graphVersion)

    // Initialize JS functions
    Component.onCompleted: Functions.init(Kirigami.Theme)

    // Content
    Plasmoid.configurationRequired: graphsModel.length === 0 // Check if graphs is valid and have some items
    preferredRepresentation: Plasmoid.configurationRequired ? compactRepresentation : fullRepresentation
    fullRepresentation: MouseArea {
        Layout.preferredWidth: !verticalLayout ? (itemWidth * graphView.model.length + itemMargin * (graphView.model.length + 1)) : itemWidth
        Layout.preferredHeight: verticalLayout ? (itemHeight * graphView.model.length + itemMargin * (graphView.model.length + 1)) : itemHeight
        LayoutMirroring.enabled: !vertical && Qt.application.layoutDirection === Qt.RightToLeft
        LayoutMirroring.childrenInherit: true

        // Click action
        //? NOTE: This is hacky way for replace "Kio.KRun" due to limitation of access to C++ in widget without deploying package
        //? This have a lot limitation due to cannot open applications with `kioclient exec`, `kstart --application` or `xdg-open`.
        Plasma5Support.DataSource {
            id: runner
            engine: "executable"
            connectedSources: []
            onNewData: disconnectSource(sourceName)
        }
        onClicked: {
            if (Plasmoid.configuration.clickActionCommand !== "") {
                runner.connectSource(Plasmoid.configuration.clickActionCommand);
            }
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
        }

        // Main Layout
        ListView {
            id: graphView
            anchors.fill: parent
            spacing: itemMargin
            orientation: verticalLayout ? ListView.Vertical : ListView.Horizontal
            interactive: false
            reuseItems: true

            // TODO: Better handle "graphs" change
            model: graphsModel

            delegate: Loader {
                required property var modelData

                width: itemWidth
                height: itemHeight

                onLoaded: {
                    item.textContainer.firstLineLabel.font.pixelSize = Qt.binding(() => root.fontPixelSize);
                    item.textContainer.secondLineLabel.font.pixelSize = Qt.binding(() => root.fontPixelSize);
                    item.textContainer.thirdLineLabel.font.pixelSize = Qt.binding(() => root.fontPixelSize);
                }
                Component.onCompleted: {
                    const filename = (modelData.type.charAt(0).toUpperCase() + modelData.type.slice(1)) + "Graph";
                    const source = `./components/graph/${filename}.qml`;

                    // Remove internal props
                    delete modelData._v;
                    delete modelData.type;

                    // Load graph
                    setSource(source, modelData);
                }
            }

            function getGraph(index) {
                const loaderItem = graphView.itemAtIndex(index);
                return loaderItem !== null ? loaderItem.item : null;
            }
        }
    }

    function _getCustomConfig(property, fallback) {
        if (Plasmoid.configuration[`custom${property.charAt(0).toUpperCase() + property.slice(1)}`]) {
            return Plasmoid.configuration[property];
        }
        return fallback;
    }
}
