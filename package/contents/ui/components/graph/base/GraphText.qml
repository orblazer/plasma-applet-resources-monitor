import QtQuick 2.9
import QtGraphicalEffects 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: graphText

    signal showValueInLabel

    property bool valueVisible: false

    // Aliases
    readonly property alias firstLineLabel: firstLineLabel
    readonly property alias secondLineLabel: secondLineLabel
    readonly property alias thirdLineLabel: thirdLineLabel

    // Text properties
    property var labels: ["", "", ""]
    property var valueColors: [theme.textColor, theme.textColor, theme.textColor]
    property var labelColors: [theme.highlightColor, theme.textColor, theme.textColor]

    property var labelsVisibleWhenZero: [true, true, true]

    // Config aliases
    property string displayment: Plasmoid.configuration.displayment // Values: always, hover, hover-hints

    // Bind config changes
    onDisplaymentChanged: {
        if (displayment === 'always-hints') {
            valueVisible = false;
            _setTextAndColor(firstLineLabel, labels[firstLineLabel.index], true);
            _setTextAndColor(secondLineLabel, labels[secondLineLabel.index], true);
            _setTextAndColor(thirdLineLabel, labels[thirdLineLabel.index], true);
        } else if (displayment === 'hover') {
            valueVisible = mouseArea.containsMouse;
            if (mouseArea.containsMouse) {
                _setLabelsState(true);
                showValueInLabel();
            } else {
                _setLabelsState(false);
            }
        } else {
            showValueInLabel();
            valueVisible = true;
        }
    }

    // Bind properties changes
    onLabelsChanged: {
        firstLineLabel.enabled = firstLineLabel.visible = labels[0] != "";
        secondLineLabel.enabled = secondLineLabel.visible = labels[1] != "";
        thirdLineLabel.enabled = thirdLineLabel.visible = labels[2] != "";
    }

    // Labels
    Flow {
        id: textContainer
        width: parent.width
        state: Plasmoid.configuration.placement // Values: top-right, top-left, bottom-right, bottom-left
        spacing: -2
        flow: Flow.TopToBottom

        // First line
        PlasmaComponents.Label {
            id: firstLineLabel
            width: parent.width
            height: contentHeight
            readonly property int index: 0

            color: getTextColor(index)

            font.pointSize: -1
        }
        PlasmaComponents.Label {
            id: secondLineLabel
            width: parent.width
            height: contentHeight
            readonly property int index: 1

            color: getTextColor(index)

            font.pointSize: -1
        }
        PlasmaComponents.Label {
            id: thirdLineLabel
            width: parent.width
            height: contentHeight
            readonly property int index: 2

            color: getTextColor(index)

            font.pointSize: -1
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
                PropertyChanges {
                    target: thirdLineLabel
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
                PropertyChanges {
                    target: thirdLineLabel
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
                PropertyChanges {
                    target: thirdLineLabel
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
                PropertyChanges {
                    target: thirdLineLabel
                    horizontalAlignment: Text.AlignRight
                }
            }
        ]
    }

    DropShadow {
        visible: Plasmoid.configuration.enableShadows
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
        hoverEnabled: displayment !== 'always' && displayment !== 'always-hints'

        property bool _firstHover: true
        property var _oldLabelsText: []
        function _saveOldLabelsText() {
            _oldLabelsText = [firstLineLabel.text + "", secondLineLabel.text + "", thirdLineLabel.text + ""];
        }

        onEntered: {
            if (displayment === 'hover-hints') {
                valueVisible = false;
                _saveOldLabelsText();

                // Show label hints
                _setTextAndColor(firstLineLabel, labels[firstLineLabel.index], true);
                _setTextAndColor(secondLineLabel, labels[secondLineLabel.index], true);
                _setTextAndColor(thirdLineLabel, labels[thirdLineLabel.index], true);
            } else if (displayment === 'hover') {
                _setLabelsState(true);
                showValueInLabel();
                valueVisible = true;
            }
        }

        onExited: {
            if (displayment === 'hover-hints') {
                // Recover old state
                _setTextAndColor(firstLineLabel, _oldLabelsText[firstLineLabel.index]);
                _setTextAndColor(secondLineLabel, _oldLabelsText[secondLineLabel.index]);
                _setTextAndColor(thirdLineLabel, _oldLabelsText[thirdLineLabel.index]);

                // Update value
                showValueInLabel();
                valueVisible = true;
            } else if (displayment === 'hover') {
                valueVisible = false;
                _setLabelsState(false);
            }
        }
    }

    function getTextColor(index, isLabel = false) {
        if (isLabel) {
            return labelColors[index] || theme.textColor;
        }
        return valueColors[index] || theme.textColor;
    }
    function _setLabelsState(state) {
        if (state) {
            firstLineLabel.visible = firstLineLabel.enabled;
            secondLineLabel.visible = secondLineLabel.enabled;
            thirdLineLabel.visible = thirdLineLabel.enabled;
        } else {
            firstLineLabel.visible = secondLineLabel.visible = thirdLineLabel.visible = false;
        }
    }
    function _setTextAndColor(label, value, isLabel = false) {
        if (!label.enabled) {
            return;
        }
        label.text = value;
        label.color = getTextColor(label.index, isLabel);
    }
}
