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
    property string placement: plasmoid.configuration.placement // Values: top-right, top-left, bottom-right, bottom-left
    property string displayment: plasmoid.configuration.displayment // Values: always, hover, hover-hints

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
        state: placement

        // First line
        PlasmaComponents.Label {
            id: firstLineInfoLabel

            text: firstLineInfoText
            color: firstLineInfoTextColor

            verticalAlignment: Text.AlignBottom
            font.pointSize: -1
            visible: false
        }
        PlasmaComponents.Label {
            id: firstLineValueLabel

            text: firstLineValue

            verticalAlignment: Text.AlignBottom
            anchors.top: firstLineInfoLabel.top
            font.pointSize: -1
        }

        // Second line
        PlasmaComponents.Label {
            id: secondLineInfoLabel

            text: secondLineInfoText
            color: secondLineInfoTextColor

            verticalAlignment: Text.AlignTop
            font.pointSize: -1
            visible: false
        }
        PlasmaComponents.Label {
            id: secondLineValueLabel

            text: secondLineValue

            anchors.top: secondLineInfoLabel.top
            verticalAlignment: Text.AlignTop
            font.pointSize: -1
            visible: secondLineInfoText != ''
        }

        states: [
            State {
                name: 'top-left'
                AnchorChanges {
                    target: firstLineInfoLabel
                    anchors.left: textContainer.left
                    anchors.top: textContainer.top
                }
                AnchorChanges {
                    target: firstLineValueLabel
                    anchors.left: textContainer.left
                }

                AnchorChanges {
                    target: secondLineInfoLabel
                    anchors.left: textContainer.left
                    anchors.top: firstLineInfoLabel.bottom
                }
                AnchorChanges {
                    target: secondLineValueLabel
                    anchors.left: textContainer.left
                }
            },
            State {
                name: 'top-right'
                AnchorChanges {
                    target: firstLineInfoLabel
                    anchors.right: textContainer.right
                    anchors.top: textContainer.top
                }
                AnchorChanges {
                    target: firstLineValueLabel
                    anchors.right: textContainer.right
                }

                AnchorChanges {
                    target: secondLineInfoLabel
                    anchors.right: textContainer.right
                    anchors.top: firstLineInfoLabel.bottom
                }
                AnchorChanges {
                    target: secondLineValueLabel
                    anchors.right: textContainer.right
                }
            },
            State {
                name: 'bottom-left'
                AnchorChanges {
                    target: firstLineInfoLabel
                    anchors.left: textContainer.left
                    anchors.bottom: secondLineInfoLabel.top
                }
                AnchorChanges {
                    target: firstLineValueLabel
                    anchors.left: textContainer.left
                }

                AnchorChanges {
                    target: secondLineInfoLabel
                    anchors.left: textContainer.left
                    anchors.bottom: textContainer.bottom
                }
                AnchorChanges {
                    target: secondLineValueLabel
                    anchors.left: textContainer.left
                }
            },
            State {
                name: 'bottom-right'
                AnchorChanges {
                    target: firstLineInfoLabel
                    anchors.right: textContainer.right
                    anchors.bottom: secondLineInfoLabel.top
                }
                AnchorChanges {
                    target: firstLineValueLabel
                    anchors.right: textContainer.right
                }

                AnchorChanges {
                    target: secondLineInfoLabel
                    anchors.right: textContainer.right
                    anchors.bottom: textContainer.bottom
                }
                AnchorChanges {
                    target: secondLineValueLabel
                    anchors.right: textContainer.right
                }
            }
        ]
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

    // Action

    onDisplaymentChanged: {
        switch (displayment) {
            case 'always':
                firstLineInfoLabel.visible = secondLineInfoLabel.visible = false
                break

            case 'hover':
                firstLineInfoLabel.visible = secondLineInfoLabel.visible = false
                firstLineValueLabel.visible = secondLineValueLabel.visible = false
                break

            case 'always':
            case 'hover-hints':
                firstLineValueLabel.visible = true
                secondLineValueLabel.visible = secondLineInfoText != ''
                break
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: displayment !== 'always'

        onEntered: {
            switch (displayment) {
                case 'hover':
                    firstLineValueLabel.visible = true
                    secondLineValueLabel.visible = secondLineInfoText != ''
                    break
                case 'hover-hints':
                    firstLineInfoLabel.visible = true
                    firstLineValueLabel.visible = false

                    if(secondLineInfoText != '') {
                        secondLineInfoLabel.visible = true
                        secondLineValueLabel.visible = false
                    }
                    break
            }
        }

        onExited: {
            switch (displayment) {
                case 'hover':
                    firstLineValueLabel.visible = secondLineValueLabel.visible = false
                    break
                case 'hover-hints':
                    firstLineInfoLabel.visible = false
                    firstLineValueLabel.visible = true

                    if(secondLineInfoText != '') {
                        secondLineInfoLabel.visible = false
                        secondLineValueLabel.visible = true
                    }
                    break
            }
        }
    }
}
