import QtQuick 2.9
import QtGraphicalEffects 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: graphText
    readonly property alias firstLineLabel: firstLineLabel
    readonly property alias secondLineLabel: secondLineLabel

    property color textColor: theme.textColor
    property string label: ''
    property color labelColor: theme.highlightColor
    property string secondLabel: ''
    property color secondLabelColor: theme.textColor

    property bool enableShadows: plasmoid.configuration.enableShadows
    property string placement: plasmoid.configuration.placement // Values: top-right, top-left, bottom-right, bottom-left
    property string displayment: plasmoid.configuration.displayment // Values: always, hover, hover-hints

    property bool valueVisible: false

    signal showValueInLabel()

    onDisplaymentChanged: {
        switch (displayment) {
            case 'always':
            case 'hover-hints':
                firstLineLabel.color = secondLineLabel.color = textColor
                showValueInLabel()
                valueVisible = true
                break

            case 'hover':
                firstLineLabel.visible = secondLineLabel.visible = false

                valueVisible = mouseArea.containsMouse
                break

            case 'always-hints':
                valueVisible = false

                firstLineLabel.text = label
                firstLineLabel.color = labelColor

                secondLineLabel.text = secondLabel
                secondLineLabel.color = secondLabelColor
                secondLineLabel.visible = secondLineLabel.text != ''
                break
        }
    }

    // Labels
    Column {
        id: textContainer
        width: parent.width
        state: placement

        // First line
        PlasmaComponents.Label {
            id: firstLineLabel
            width: parent.width
            height: contentHeight

            text: label
            color: labelColor

            font.pointSize: -1
        }
        PlasmaComponents.Label {
            id: secondLineLabel
            width: parent.width
            height: contentHeight
            property string lastValue: ''

            text: secondLabel
            color: secondLabelColor

            font.pointSize: -1
            visible: secondLabel != ''
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
                    target: firstLineLabel
                    horizontalAlignment: Text.AlignLeft
                }
                PropertyChanges {
                    target: secondLineLabel
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
                    target: firstLineLabel
                    horizontalAlignment: Text.AlignRight
                }
                PropertyChanges {
                    target: secondLineLabel
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
                    target: firstLineLabel
                    horizontalAlignment: Text.AlignLeft
                }
                PropertyChanges {
                    target: secondLineLabel
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
                    target: firstLineLabel
                    horizontalAlignment: Text.AlignRight
                }
                PropertyChanges {
                    target: secondLineLabel
                    horizontalAlignment: Text.AlignRight
                }
            }
        ]
    }

    DropShadow {
        visible: enableShadows
        anchors.fill: textContainer
        radius: 1
        spread: 1
        fast: true
        color: theme.backgroundColor
        source: textContainer
    }

    // Action
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: displayment !== 'always'

        onEntered: {
            switch (displayment) {
                case 'hover':
                    valueVisible = true

                    firstLineLabel.visible = true
                    secondLineLabel.visible = secondLineLabel.text != ''
                    break
                case 'hover-hints':
                    valueVisible = false

                    firstLineLabel.text = label
                    firstLineLabel.color = labelColor
                    firstLineLabel.visible = true

                    secondLineLabel.text = secondLabel
                    secondLineLabel.color = secondLabelColor
                    secondLineLabel.visible = secondLineLabel.text != ''
                    break
            }
        }

        onExited: {
            switch (displayment) {
                case 'hover':
                    valueVisible = false

                    firstLineLabel.visible = secondLineLabel.visible = false
                    break
                case 'hover-hints':
                    firstLineLabel.color = secondLineLabel.color = textColor
                    showValueInLabel()
                    valueVisible = true
                    break
            }
        }
    }
}
