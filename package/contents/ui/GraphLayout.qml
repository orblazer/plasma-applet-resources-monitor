import QtQuick

Flow {
    id: root

    property alias model: repeater.model
    property alias updateInterval: updater.interval

    required property double itemWidth
    required property double itemHeight
    required property double fontPixelSize
    required property double fontScaleModifier
    property bool isVertical: false

    // Manage flow and centering
    flow: isVertical ? Flow.TopToBottom : Flow.LeftToRight
    anchors.horizontalCenter: isVertical ? parent.horizontalCenter : undefined
    anchors.verticalCenter: !isVertical ? parent.verticalCenter : undefined

    Repeater {
        id: repeater

        delegate: Loader {
            required property var modelData

            width: root.itemWidth
            height: root.itemHeight

            onLoaded: {
                if (item.objectName === "Text") {
                    item.fontScaleModifier = Qt.binding(() => root.fontScaleModifier);
                } else {
                    item.textContainer.fontSize = Qt.binding(() => root.fontPixelSize);
                }
            }
            Component.onCompleted: {
                const typeCapitalized = modelData.type.charAt(0).toUpperCase() + modelData.type.slice(1);
                // Retrieve props without un wanted internals
                let props = {};
                for (const [key, value] of Object.entries(modelData)) {
                    if (key === "_v" || key === "type") {
                        continue;
                    }
                    props[key] = value;
                }

                // Load graph
                if (typeCapitalized.endsWith("Text")) {
                    setSource(Qt.resolvedUrl(`./components/text/${typeCapitalized}.qml`), props);
                } else {
                    setSource(Qt.resolvedUrl(`./components/graph/${typeCapitalized}Graph.qml`), props);
                }
            }
        }
    }

    function getGraph(index) {
        return root.children[index]?.item;
    }

    // Global update timer
    Timer {
        id: updater

        running: true
        repeat: true

        onTriggered: {
            for (let i = 0; i < root.model.length + 1; i++) {
                const graph = root.getGraph(i);
                if (typeof graph !== "undefined" && graph.objectName !== "Text") {
                    graph._update();
                }
            }
        }
    }
}
