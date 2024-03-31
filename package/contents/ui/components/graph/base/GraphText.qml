import QtQuick
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Item {
    id: root
    visible: enabled

    signal showValues

    property bool valueVisible: false
    property var textElide: valueVisible ? Text.ElideNone : (LayoutMirroring.enabled ? Text.ElideLeft : Text.ElideRight)

    // Aliases
    readonly property alias firstLine: firstLine
    readonly property alias secondLine: secondLine
    readonly property alias thirdLine: thirdLine

    // Text properties
    property var hints: ["", "", ""]
    property var valueColors: [undefined, undefined, undefined]
    property var hintColors: [undefined, undefined, undefined]
    property int fontSize: -1
    property var labelsVisibleWhenZero: [true, true, true]

    // Config aliases
    property string displayment: Plasmoid.configuration.displayment // Values: always, hover, hover-hints, never
    property var textStyle: Plasmoid.configuration.enableShadows ? Text.Outline : Text.Normal
    property var _hintColors: [Kirigami.Theme.highlightColor, undefined, undefined] // Internal
    property var _valueColors: [undefined, undefined, undefined] // Internal

    // Bind config changes
    onDisplaymentChanged: {
        if (displayment === 'hover') {
            valueVisible = mouseArea.containsMouse;
            if (!mouseArea.containsMouse) {
                _hideLines();
                return;
            }
        }
        _showValues();
    }

    // Bind properties changes
    onValueColorsChanged: {
        // Resolve colors
        _valueColors = valueColors.map(v => root._resolveColor(v));
    }
    onHintColorsChanged: {
        // Resolve colors
        _hintColors = hintColors.map(v => root._resolveColor(v));
    }

    // Labels
    Column {
        id: textContainer
        width: parent.width
        state: Plasmoid.configuration.placement // Values: top-right, top-left, bottom-right, bottom-left
        spacing: -2

        // First line
        Text {
            id: firstLine
            readonly property int index: 0
            text: "..."

            width: parent.width

            textFormat: Text.PlainText
            elide: textElide
            color: getTextColor(index)
            style: textStyle
            styleColor: Kirigami.Theme.backgroundColor
            font.pixelSize: fontSize
        }
        Text {
            id: secondLine
            readonly property int index: 1
            text: "..."

            width: parent.width
            enabled: hints[index] !== ""
            visible: enabled

            textFormat: Text.PlainText
            elide: textElide
            color: getTextColor(index)
            style: textStyle
            styleColor: Kirigami.Theme.backgroundColor
            font.pixelSize: fontSize
        }
        Text {
            id: thirdLine
            readonly property int index: 2
            text: "..."

            width: parent.width
            enabled: hints[index] !== ""
            visible: enabled

            color: getTextColor(index)
            textFormat: Text.PlainText
            elide: textElide
            style: textStyle
            styleColor: Kirigami.Theme.backgroundColor
            font.pixelSize: fontSize
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
                    target: firstLine
                    horizontalAlignment: Text.AlignLeft
                }
                PropertyChanges {
                    target: secondLine
                    horizontalAlignment: Text.AlignLeft
                }
                PropertyChanges {
                    target: thirdLine
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
                    target: firstLine
                    horizontalAlignment: Text.AlignRight
                }
                PropertyChanges {
                    target: secondLine
                    horizontalAlignment: Text.AlignRight
                }
                PropertyChanges {
                    target: thirdLine
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
                    target: firstLine
                    horizontalAlignment: Text.AlignLeft
                }
                PropertyChanges {
                    target: secondLine
                    horizontalAlignment: Text.AlignLeft
                }
                PropertyChanges {
                    target: thirdLine
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
                    target: firstLine
                    horizontalAlignment: Text.AlignRight
                }
                PropertyChanges {
                    target: secondLine
                    horizontalAlignment: Text.AlignRight
                }
                PropertyChanges {
                    target: thirdLine
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

        onEntered: {
            if (displayment === 'hover-hints') {
                valueVisible = false;

                // Show label hints
                _showHint(firstLine);
                _showHint(secondLine);
                _showHint(thirdLine);
            } else if (displayment === 'hover') {
                _showValues();
            }
        }

        onExited: {
            if (displayment === 'hover-hints') {
                // Reset colors
                firstLine.color = getTextColor(firstLine.index);
                secondLine.color = getTextColor(secondLine.index);
                thirdLine.color = getTextColor(thirdLine.index);

                // Update values
                _showValues();
            } else if (displayment === 'hover') {
                _hideLines();
            }
        }
    }

    function getLabel(index) {
        if (index === 0) {
            return firstLine;
        } else if (index === 1) {
            return secondLine;
        } else if (index === 2) {
            return thirdLine;
        }
        return undefined;
    }

    function getTextColor(index) {
        return _valueColors[index];
    }

    function _showValues() {
        valueVisible = true;
        firstLine.visible = firstLine.enabled;
        secondLine.visible = secondLine.enabled;
        thirdLine.visible = thirdLine.enabled;
        showValues();
    }
    function _showHint(label) {
        if (!label.enabled) {
            return;
        }
        label.visible = true;
        label.text = hints[label.index];
        label.color = _hintColors[label.index];
    }
    function _hideLines() {
        valueVisible = false;
        firstLine.visible = false;
        secondLine.visible = false;
        thirdLine.visible = false;
    }

    /**
     * Resolve color when is name based
     * @param {string} color The color value
     * @returns The color color
     */
    function _resolveColor(color) {
        if (!color) {
            return Kirigami.Theme.textColor;
        } else if (color.startsWith("#")) {
            return color;
        }
        return Kirigami.Theme[color] ?? Kirigami.Theme.textColor;
    }
}
