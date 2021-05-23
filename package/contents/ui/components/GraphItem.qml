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
import QtGraphicalEffects 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

import "./"

Item {
    id: graphItem

    property alias firstLineInfoLabel: firstLineInfoLabel
    property alias firstLineValueLabel: firstLineValueLabel
    property alias secondLineInfoLabel: secondLineInfoLabel
    property alias secondLineValueLabel: secondLineValueLabel

    // Text properties
    property string firstLineInfoText
    property color firstLineInfoTextColor: theme.highlightColor
    property string firstLineValue: '...'
    property string secondLineInfoText: ''
    property color secondLineInfoTextColor: theme.textColor
    property string secondLineValue: ''
    property bool enableShadows: plasmoid.configuration.enableShadows
    property bool enableHints: plasmoid.configuration.enableHints

    // Graph properties
    property var firstGraphModel
    property color firstGraphBarColor: theme.highlightColor
    property var secondGraphModel
    property color secondGraphBarColor: theme.textColor

    HistoryGraph {
        listViewModel: firstGraphModel
        barColor: firstGraphBarColor
    }

    HistoryGraph {
        visible: secondLineInfoText != ''
        listViewModel: secondGraphModel
        barColor: secondGraphBarColor
    }

    Item {
        id: textContainer
        anchors.fill: parent

        // First line
        PlasmaComponents.Label {
            id: firstLineInfoLabel

            text: firstLineInfoText
            color: firstLineInfoTextColor

            anchors.right: parent.right
            verticalAlignment: Text.AlignTop
            font.pointSize: -1
            visible: false
        }
        PlasmaComponents.Label {
            id: firstLineValueLabel

            text: firstLineValue

            anchors.right: parent.right
            verticalAlignment: Text.AlignTop
            font.pointSize: -1
        }

        // Second line
        PlasmaComponents.Label {
            id: secondLineInfoLabel

            text: secondLineInfoText
            color: secondLineInfoTextColor

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            font.pointSize: -1
            visible: false
        }
        PlasmaComponents.Label {
            id: secondLineValueLabel

            text: secondLineValue

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            font.pointSize: -1
            visible: secondLineInfoText != ''
        }
    }

    DropShadow {
        visible: enableShadows
        anchors.fill: textContainer
        radius: 3
        samples: 8
        spread: 0.8
        fast: true
        color: theme.backgroundColor
        source: textContainer
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: enableHints

        onEntered: {
            firstLineInfoLabel.visible = true
            firstLineValueLabel.visible = false

            if(secondLineInfoText != '') {
                secondLineInfoLabel.visible = true
                secondLineValueLabel.visible = false
            }
        }

        onExited: {
            firstLineInfoLabel.visible = false
            firstLineValueLabel.visible = true

            if(secondLineInfoText != '') {
                secondLineInfoLabel.visible = false
                secondLineValueLabel.visible = true
            }
        }
    }
}
