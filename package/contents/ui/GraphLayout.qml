import QtQuick

Flow {
    id: root

    property alias model: repeater.model
    property alias updateInterval: updater.interval

    required property double itemWidth
    required property double itemHeight
    required property double fontPixelSize
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
                item.textContainer.fontSize = Qt.binding(() => root.fontPixelSize);
            }
            Component.onCompleted: {
                const typeCaptitalized = modelData.type.charAt(0).toUpperCase() + modelData.type.slice(1);
                // Retrieve props without un wanted internals
                let props = {};
                for (const [key, value] of Object.entries(modelData)) {
                    if (key === "_v" || key === "type") {
                        continue;
                    }
                    props[key] = value;
                }

                // Load graph
                setSource(Qt.resolvedUrl(`./components/graph/${typeCaptitalized}Graph.qml`), props);
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
                if (typeof graph !== "undefined") {
                    graph._update();
                }
            }
        }
    }
}
