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

    // Text properties
    property var hints: ["", "", ""]
    property var valueColors: [undefined, undefined]
    property var hintColors: [undefined, undefined]
    property int fontSize: -1

    // Config aliases
    property string displayment: Plasmoid.configuration.displayment // Values: always, hover, hover-hints, never
    property var textStyle: Plasmoid.configuration.enableShadows ? Text.Outline : Text.Normal
    property var _hintColors: [undefined, undefined] // Internal
    property var _valueColors: [undefined, undefined] // Internal

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
        anchors.verticalCenter: parent.verticalCenter
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

            textFormat: Text.PlainText
            elide: textElide
            color: getTextColor(index)
            style: textStyle
            styleColor: Kirigami.Theme.backgroundColor
            font.pixelSize: fontSize
        }
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
            } else if (displayment === 'hover') {
                _showValues();
            }
        }

        onExited: {
            if (displayment === 'hover-hints') {
                // Reset colors
                firstLine.color = getTextColor(firstLine.index);
                secondLine.color = getTextColor(secondLine.index);

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
