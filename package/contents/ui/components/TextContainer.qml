import QtQuick
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Item {
    id: root
    visible: enabled
    anchors.fill: parent

    // Properties
    property int lineCount: 3
    property var hints: ["", "", ""]
    property var valueColors: [undefined, undefined, undefined]
    property var hintColors: [undefined, undefined, undefined]
    property int fontSize: -1
    property var labelsVisibleWhenZero: [true, true, true]
    property int thresholdIndex: -1 // Sensor index used for threshold
    property var thresholds: [] // format: [warning, critical]

    // Config aliases
    property string displayment: Plasmoid.configuration.displayment // Values: always, hover, hover-hints, never
    property string placement: Plasmoid.configuration.placement // Values: top-right, top-left, bottom-right, bottom-left, center (only for text graphs)
    property var defaultColor: Plasmoid.configuration.textColor
    readonly property color thresholdWarningColor: _resolveColor(Plasmoid.configuration.warningColor)
    readonly property color thresholdCriticalColor: _resolveColor(Plasmoid.configuration.criticalColor)

    property string labelState: {
        // Values: value, hint, none
        if (displayment === "hover") {
            return mouseArea.containsMouse ? "value" : "none";
        } else if (displayment === "hover-hints" && mouseArea.containsMouse) {
            return "hint";
        }
        return "value";
    }
    property var textStyle: Plasmoid.configuration.enableShadows ? Text.Outline : Text.Normal
    property var textElide: labelState === "value" ? Text.ElideNone : (LayoutMirroring.enabled ? Text.ElideLeft : Text.ElideRight)
    property int horizontalAlignment: (placement === "center") ? Text.AlignHCenter : ((placement === "top-left" || placement === "bottom-left") ? Text.AlignLeft : Text.AlignRight)

    // Labels
    Column {
        id: textContainer
        width: parent.width
        spacing: -2

        anchors.top: root.placement.startsWith("top") ? parent.top : undefined
        anchors.bottom: root.placement.startsWith("bottom") ? parent.bottom : undefined
        anchors.verticalCenter: root.placement === "center" ? parent.verticalCenter : undefined

        Loader {
            id: firstLine
            sourceComponent: labelComponent
            width: parent.width
            readonly property int index: 0
        }
        Loader {
            id: secondLine
            enabled: lineCount >= 2
            visible: enabled
            sourceComponent: labelComponent
            width: parent.width
            readonly property int index: 1
        }
        Loader {
            id: thirdLine
            enabled: lineCount == 3
            visible: enabled
            sourceComponent: labelComponent
            width: parent.width
            readonly property int index: 2
        }
    }

    // Action
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: root.displayment !== 'always'
    }

    /**
     * Get label by its index
     * @param {number} index The label index
     */
    function getLabel(index) {
        if (index === 0) {
            return firstLine.item;
        } else if (index === 1) {
            return secondLine.item;
        } else if (index === 2) {
            return thirdLine.item;
        }
        return undefined;
    }

    /**
     * Set value on label
     * @param {number} index The label index
     * @param {number} value The raw value (for threshold)
     * @param {string} formattedValue The displayed text
     */
    function setValue(index, value, formattedValue) {
        // Retrieve label need to update and data
        const label = getLabel(index);
        if (typeof label === "undefined" || !label.enabled) {
            return;
        }

        // Hide can't be zero label
        if (!labelsVisibleWhenZero[index] && value === 0) {
            label.valueText = '';
            label.visible = false;
            return;
        } else if (index === thresholdIndex && thresholds.length > 0) {
            // Handle threshold value
            if (value >= thresholds[1]) {
                label.overrideColor(thresholdCriticalColor);
            } else if (value >= thresholds[0]) {
                label.overrideColor(thresholdWarningColor);
            } else {
                label.resetColor();
            }
        }

        // Show value on label
        label.valueText = formattedValue;
        label.visible = true;
    }

    /**
     * Resolve color when is name based
     * @param {string} color The color value
     * @returns The color color
     */
    function _resolveColor(color) {
        if (!color) {
            return _resolveColor(defaultColor);
        } else if (color.startsWith("#")) {
            return color;
        }
        return Kirigami.Theme[color] ?? Kirigami.Theme.textColor;
    }

    Component {
        id: labelComponent

        Text {
            property string valueText: "..."

            property color _overrideColor: "transparent"
            property bool useOverrideColor: false

            enabled: root.hints[index] !== ""
            visible: enabled && (root.labelState !== "none")

            text: {
                if (root.labelState === "value") {
                    return valueText;
                } else if (root.labelState === "hint") {
                    return root.hints[index];
                }
                return "";
            }
            color: {
                if (root.labelState === "value") {
                    if (useOverrideColor) {
                        return _overrideColor;
                    }
                    return root._resolveColor(root.valueColors[index]);
                } else if (root.labelState === "hint") {
                    return root._resolveColor(root.hintColors[index]);
                }
                return Kirigami.Theme.textColor;
            }

            horizontalAlignment: root.horizontalAlignment
            textFormat: Text.PlainText
            elide: root.textElide
            style: root.textStyle
            styleColor: Kirigami.Theme.backgroundColor
            font.pixelSize: root.fontSize

            function overrideColor(color) {
                _overrideColor = color;
                useOverrideColor = true;
            }
            function resetColor() {
                useOverrideColor = false;
            }
        }
    }
}
