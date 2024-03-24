import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

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
    property var valueColors: [Kirigami.Theme.textColor, Kirigami.Theme.textColor, Kirigami.Theme.textColor]
    property var labelColors: [Kirigami.Theme.highlightColor, Kirigami.Theme.textColor, Kirigami.Theme.textColor]

    property var labelsVisibleWhenZero: [true, true, true]

    // Config aliases
    property string displayment: Plasmoid.configuration.displayment // Values: always, hover, hover-hints, never

    // Bind config changes
    onDisplaymentChanged: {
        if (displayment === 'hover') {
            valueVisible = mouseArea.containsMouse;
            _setLabelsState(valueVisible);
            if (mouseArea.containsMouse) {
                showValueInLabel();
            }
        } else {
            _setLabelsState(true);
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

            text: "..."
            color: getTextColor(index)
            style: plasmoid.configuration.enableShadows ? Text.Outline : Text.Normal
            styleColor: Kirigami.Theme.backgroundColor
            font.pointSize: -1
        }
        PlasmaComponents.Label {
            id: secondLineLabel
            width: parent.width
            height: contentHeight
            readonly property int index: 1

            text: "..."
            color: getTextColor(index)
            style: plasmoid.configuration.enableShadows ? Text.Outline : Text.Normal
            styleColor: Kirigami.Theme.backgroundColor
            font.pointSize: -1
        }
        PlasmaComponents.Label {
            id: thirdLineLabel
            width: parent.width
            height: contentHeight
            readonly property int index: 2

            text: "..."
            color: getTextColor(index)
            style: plasmoid.configuration.enableShadows ? Text.Outline : Text.Normal
            styleColor: Kirigami.Theme.backgroundColor
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

    // Action
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: displayment !== 'always'

        property bool _firstHover: true
        property var _oldLabelsState: []
        function _saveOldLabelsState() {
            _oldLabelsState = [[firstLineLabel.text + "", !!firstLineLabel.visible], [secondLineLabel.text + "", !!secondLineLabel.visible], [thirdLineLabel.text + "", !!thirdLineLabel.visible]];
        }

        onEntered: {
            if (displayment === 'hover-hints') {
                valueVisible = false;
                _saveOldLabelsState();
                _setLabelsState(true);

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
                _setTextAndColor(firstLineLabel, _oldLabelsState[firstLineLabel.index][0]);
                firstLineLabel.visible = _oldLabelsState[firstLineLabel.index][1];
                _setTextAndColor(secondLineLabel, _oldLabelsState[secondLineLabel.index][0]);
                secondLineLabel.visible = _oldLabelsState[secondLineLabel.index][1];
                _setTextAndColor(thirdLineLabel, _oldLabelsState[thirdLineLabel.index][0]);
                thirdLineLabel.visible = _oldLabelsState[thirdLineLabel.index][1];

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
            return labelColors[index] || Kirigami.Theme.textColor;
        }
        return valueColors[index] || Kirigami.Theme.textColor;
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
