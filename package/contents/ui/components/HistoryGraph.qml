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

Item {
    id: historyGraph

    anchors.fill: parent

    property var listViewModel
    property color barColor

    ListView {
        id: listView
        anchors.fill: parent

        interactive: false
        orientation: Qt.Horizontal
        layoutDirection: Qt.LeftToRight
        spacing: 0

        model: listViewModel

        delegate: Rectangle {
            width: historyGraph.width / graphGranularity
            height: historyGraph.height * graphItemPercent
            x: 0
            y: panel.height - height
            color: barColor
            radius: 3
        }
    }

}
