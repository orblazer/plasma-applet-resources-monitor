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
    
    width: parent.width
    height: parent.height
    
    property var listViewModel
    property color barColor
    property double minBarHeight: 0
    
    ListView {
        anchors.fill: parent
        
        interactive: false
        orientation: Qt.Horizontal
        layoutDirection: Qt.LeftToRight
        spacing: 0
        
        model: listViewModel
        
        delegate: Item {
            
            property double rectHeight: Math.max(graphItemHeight, minBarHeight)
            
            width: historyGraph.width / graphGranularity
            height: historyGraph.height
            
            Rectangle {
                width: parent.width
                height: rectHeight
                x: 0
                y: parent.height - height
                color: barColor
                radius: 3
            }
        }
    }
    
}