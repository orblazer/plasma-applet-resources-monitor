import QtQuick
import QtQuick.Layouts

Flow {
    id: root

    property alias model: repeater.model
    property alias updateInterval: updater.interval

    property bool isVertical: false

    property int parentWidth: 0
    property int parentHeight: 0

    // Width left to share between items without an explicit width, so the row fills parentWidth
    property real autoWidth: {
        if (isVertical)
            return 0;

        let fixedWidth = 0;
        let autoCount = 0;
        let visibleCount = 0;
        for (let i = 0; i < repeater.count; i++) {
            const loaderItem = repeater.itemAt(i);
            if (!loaderItem?.item?.visible)
                continue;

            visibleCount++;
            if (loaderItem.modelData.sizes[0] !== -1) {
                fixedWidth += loaderItem.modelData.sizes[0];
            } else {
                autoCount++;
            }
        }
        if (autoCount === 0)
            return 0;

        const remaining = root.parentWidth - fixedWidth - root.spacing * Math.max(visibleCount - 1, 0);
        return Math.max(0, remaining / autoCount);
    }

    flow: isVertical ? GridLayout.TopToBottom : GridLayout.LeftToRight

    Repeater {
        id: repeater

        delegate: Loader {
            required property var modelData

            width: {
                if (!item?.visible)
                    return 0;
                if (modelData.sizes[0] !== -1)
                    return modelData.sizes[0];
                if (root.isVertical)
                    return root.parentWidth;

                return Math.max(item?.minimumWidth ?? 0, root.autoWidth);
            }
            height: {
                if (!item?.visible)
                    return 0;
                if (modelData.sizes[1] !== -1)
                    return modelData.sizes[1];

                return root.isVertical ? root.parentWidth : root.parentHeight;
            }

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
