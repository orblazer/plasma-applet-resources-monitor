import QtQuick
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Item {
    id: root
    objectName: "Text"

    // Settings
    property string device: "Text" // Text value
    property string color: undefined // Text color
    property string placement: "middle-right" // Text placement
    property int size: 24 // Font size

    // Aliases
    readonly property alias firstLine: firstLine

    // Text properties
    property var textElide: LayoutMirroring.enabled ? Text.ElideLeft : Text.ElideRight
    property double fontScaleModifier: -1

    // Config aliases
    property var defaultColor: Plasmoid.configuration.textColor
    property var textStyle: Plasmoid.configuration.enableShadows ? Text.Outline : Text.Normal

    // Labels
    Column {
        id: textContainer
        width: parent.width
        state: placement // Values: top-right, top-left, bottom-right, bottom-left, middle-left, middle-right

        // First line
        Text {
            id: firstLine
            text: root.device
            color: root._resolveColor(root.color)

            width: parent.width

            textFormat: Text.PlainText
            elide: textElide
            style: textStyle
            styleColor: Kirigami.Theme.backgroundColor
            font.pixelSize: Math.round(fontScaleModifier * (size / 100))
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
            },
            State {
                name: 'middle-left'
                AnchorChanges {
                    target: textContainer
                    anchors.verticalCenter: parent.verticalCenter
                }

                PropertyChanges {
                    target: firstLine
                    horizontalAlignment: Text.AlignLeft
                }
            },
            State {
                name: 'middle-right'
                AnchorChanges {
                    target: textContainer
                    anchors.verticalCenter: parent.verticalCenter
                }

                PropertyChanges {
                    target: firstLine
                    horizontalAlignment: Text.AlignRight
                }
            }
        ]
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
}
