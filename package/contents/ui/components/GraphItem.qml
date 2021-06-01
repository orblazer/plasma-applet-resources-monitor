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

    Column {
        id: textContainer
        width: parent.width
        state: placement

        // First line
        PlasmaComponents.Label {
            id: firstLineInfoLabel
            width: parent.width
            height: contentHeight

            text: firstLineInfoText
            color: firstLineInfoTextColor

            font.pointSize: -1
            visible: false
        }
        PlasmaComponents.Label {
            id: firstLineValueLabel
            width: parent.width
            height: contentHeight

            text: firstLineValue

            font.pointSize: -1
        }

        // Second line
        PlasmaComponents.Label {
            id: secondLineInfoLabel
            width: parent.width
            height: contentHeight

            text: secondLineInfoText
            color: secondLineInfoTextColor

            font.pointSize: -1
            visible: false
        }
        PlasmaComponents.Label {
            id: secondLineValueLabel
            width: parent.width
            height: contentHeight

            text: secondLineValue

            font.pointSize: -1
            visible: secondLineInfoText != ''
        }

        // States
        states: [
            State {
                name: 'top-left'
                AnchorChanges {
                    target: textContainer
                    anchors.top: parent.top
                }

                PropertyChanges {
                    target: firstLineInfoLabel
                    horizontalAlignment: Text.AlignLeft
                }
                PropertyChanges {
                    target: firstLineValueLabel
                    horizontalAlignment: Text.AlignLeft
                }

                PropertyChanges {
                    target: secondLineInfoLabel
                    horizontalAlignment: Text.AlignLeft
                }
                PropertyChanges {
                    target: secondLineValueLabel
                    horizontalAlignment: Text.AlignLeft
                }
            },
            State {
                name: 'top-right'
                AnchorChanges {
                    target: textContainer
                    anchors.top: parent.top
                }

                PropertyChanges {
                    target: firstLineInfoLabel
                    horizontalAlignment: Text.AlignRight
                }
                PropertyChanges {
                    target: firstLineValueLabel
                    horizontalAlignment: Text.AlignRight
                }

                PropertyChanges {
                    target: secondLineInfoLabel
                    horizontalAlignment: Text.AlignRight
                }
                PropertyChanges {
                    target: secondLineValueLabel
                    horizontalAlignment: Text.AlignRight
                }
            },

            State {
                name: 'bottom-left'
                AnchorChanges {
                    target: textContainer
                    anchors.bottom: parent.bottom
                }

                PropertyChanges {
                    target: firstLineInfoLabel
                    horizontalAlignment: Text.AlignLeft
                }
                PropertyChanges {
                    target: firstLineValueLabel
                    horizontalAlignment: Text.AlignLeft
                }

                PropertyChanges {
                    target: secondLineInfoLabel
                    horizontalAlignment: Text.AlignLeft
                }
                PropertyChanges {
                    target: secondLineValueLabel
                    horizontalAlignment: Text.AlignLeft
                }
            },
            State {
                name: 'bottom-right'
                AnchorChanges {
                    target: textContainer
                    anchors.bottom: parent.bottom
                }

                PropertyChanges {
                    target: firstLineInfoLabel
                    horizontalAlignment: Text.AlignRight
                }
                PropertyChanges {
                    target: firstLineValueLabel
                    horizontalAlignment: Text.AlignRight
                }

                PropertyChanges {
                    target: secondLineInfoLabel
                    horizontalAlignment: Text.AlignRight
                }
                PropertyChanges {
                    target: secondLineValueLabel
                    horizontalAlignment: Text.AlignRight
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
                secondLineValueLabel.visible = secondLineInfoText != '' && secondLineValueLabel.enabled
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
                    secondLineValueLabel.visible = secondLineInfoText != '' && secondLineValueLabel.enabled
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
                        secondLineValueLabel.visible = secondLineValueLabel.enabled
                    }
                    break
            }
        }
    }
}
