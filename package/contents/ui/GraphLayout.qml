import QtQuick
import QtQuick.Layouts

Flow {
    id: root

    property alias model: repeater.model
    property alias updateInterval: updater.interval

    property bool isVertical: false
    property double widthRatio: 1.4

    property int parentWidth: 0
    property int parentHeight: 0

    flow: isVertical ? GridLayout.TopToBottom : GridLayout.LeftToRight

    Repeater {
        id: repeater

        delegate: Loader {
            required property var modelData

            width: {
                if (modelData.sizes[0] !== -1) return modelData.sizes[0]
                if (root.isVertical) return root.parentWidth
                if (modelData.type.endsWith("Text"))  {
                    return Math.max(item?.minimumWidth ?? 0, root.parentHeight)
                }
                return Math.max(item?.minimumWidth ?? 0, Math.round(root.parentHeight * root.widthRatio))
            }
            height: modelData.sizes[1] === -1 ? (root.isVertical ? root.parentWidth : root.parentHeight) : modelData.sizes[1]

            Component.onCompleted: {
                const typeCapitalized = modelData.type.charAt(0).toUpperCase() + modelData.type.slice(1);
                // Retrieve props without un wanted internals
                let props = {};
                for (const [key, value] of Object.entries(modelData)) {
                    if (["_v", "type", "sizes"].includes(key)) {
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
