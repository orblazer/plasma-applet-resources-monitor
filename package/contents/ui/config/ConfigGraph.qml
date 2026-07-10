import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../components" as RMComponents
import "./dialog" as RMDialogs
import "../code/graphs.js" as GraphFns

GraphListPage {
    id: root

    property bool graphsUpgraded: false

    // Config properties
    property var cfg_graphs: "[]"
    property var graphs: []

    //#region // HACK: Present to suppress errors (https://bugs.kde.org/show_bug.cgi?id=484541)
    property var cfg_fillPanel
    property var cfg_historyAmount
    property var cfg_customGraphWidth
    property var cfg_graphWidth
    property var cfg_customGraphHeight
    property var cfg_graphHeight
    property var cfg_graphSpacing
    property var cfg_graphFillOpacity
    property var cfg_enableShadows
    property var cfg_fontScale
    property var cfg_placement
    property var cfg_displayment
    property var cfg_warningColor
    property var cfg_criticalColor
    property var cfg_updateInterval
    property var cfg_clickApplication
    //#endregion

    // Remove upgrade message after saved
    function saveConfig() {
        graphsUpgraded = false;
    }

    // Retrieve available graphs
    AvailableGraphProxy {
        id: availableGraphs

        onInitialized: {
            root.graphs = GraphFns.parse(root.cfg_graphs, true) || [];
            Object.values(root.graphs).forEach(v => root.addItem(v, find(v.type, v.device ?? v.type)));
            root.graphsUpgraded = root.graphs[0]?._changed ?? false;
            if (root.graphsUpgraded) {
                root.updateGraphsSetting();
            }

            // Uncomment for development
            /* addGraph("gpu", "all");
            addGraph("gpu", "gpu1");
            addGraph("network");
            addGraph("disk", "all"); */
        }
        onRowsInserted: (parent, first, last) => {
            for (let i = first; i <= last; ++i) {
                const graph = get(i);
                if (typeof graph != "undefined") {
                    root.updateItem(graph);
                }
            }
        }
        onDataChanged: index => {
            const graph = get(index.row);
            if (typeof graph != "undefined") {
                root.updateItem(graph);
            }
        }
    }

    // Actions
    onAction: (type, payload) => {
        switch (type) {
        case "add":
            addDialog.open();
            break;
        case "move":
            root.graphs.splice(payload.newIndex, 0, root.graphs.splice(payload.oldIndex, 1)[0]);
            break;
        case "save":
            root.updateGraphsSetting();
            break;
        case "fix":
            fixDialog.openFor(payload.index, payload.name);
            break;
        case "edit":
            editDialog.openFor(payload.index, payload.name);
            break;
        case "remove":
            removePrompt.openFor(payload.index, payload.name);
            break;
        }
    }

    // Add dialog
    RMDialogs.AddDialog {
        id: addDialog
        sourceModel: availableGraphs
        graphs: root.graphs

        width: root.width - Kirigami.Units.gridUnit * 4
        height: root.height - Kirigami.Units.gridUnit * 4

        onSelected: items => {
            for (const item of items) {
                addGraph(item.type, item.device);
            }
        }
    }

    // Edit dialog
    Kirigami.Dialog {
        id: editDialog
        width: root.width - Kirigami.Units.gridUnit * 4
        height: root.height - Kirigami.Units.gridUnit * 4

        title: i18nc("@title:window", "Edit graph: %1", graphName)
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel

        property int graphIndex
        property string graphName

        property bool needSave: false
        onAccepted: {
            if (needSave) {
                graphs[graphIndex] = contentLoader.item.item;
                if (contentLoader.item.item.type == "text") {
                    root.setItem(graphIndex, graphs[graphIndex]);
                }
                updateGraphsSetting();
            }
        }

        contentItem: Loader {
            id: contentLoader

            onLoaded: {
                editDialog.open();
                item.onChanged.connect(onChanged);
            }

            // Handle config change
            function onChanged() {
                editDialog.needSave = true;
            }
        }

        /**
         * Open edit modal for specific graph
         * @param {number} index The graph index
         * @param {string} name The graph name
         */
        function openFor(index, name) {
            const item = graphs[index];
            const filename = "Edit" + (item.type.charAt(0).toUpperCase() + item.type.slice(1));
            const source = `./dialog/${filename}.qml`;

            // Load settings page
            graphIndex = index;
            graphName = name;
            contentLoader.setSource(source, {
                item
            });
        }
    }

    // Fix dialog
    Kirigami.Dialog {
        id: fixDialog
        // width: graphsView.width - Kirigami.Units.gridUnit * 4
        // height: graphsView.height

        title: i18nc("@title:window", "Edit graph: %1", graphName)
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel

        property int graphIndex
        property string graphName

        onAccepted: {
            const newGraph = graphs[graphIndex];
            newGraph.device = newGpuIndexes.currentValue;
            graphs[graphIndex] = newGraph;
            graphsView.model.set(graphIndex, {
                type: newGraph.type,
                device: newGraph.device
            });
            root.updateGraphsSetting();
        }

        Kirigami.Page {
            Kirigami.FormLayout {
                QQC2.ComboBox {
                    id: newGpuIndexes
                    Layout.fillWidth: true
                    Kirigami.FormData.label: i18n("New GPU:")

                    textRole: "name"
                    valueRole: "device"
                }
            }
        }

        /**
         * Open edit modal for specific graph
         * @param {number} index The graph index
         * @param {string} name The graph name
         */
        function openFor(index, name) {
            if (typeof newGpuIndexes.model === "undefined") {
                newGpuIndexes.model = availableGraphs.findAllType("gpu", true).map(item => ({
                            name: item.deviceName,
                            device: item.device
                        }));
            }

            // Load settings page
            graphIndex = index;
            graphName = name;
            fixDialog.open();
        }
    }

    // Remove dialog
    Kirigami.PromptDialog {
        id: removePrompt

        property int graphIndex: -1
        property string graphName: ""

        title: i18nc("@title:window", "Remove graph")
        subtitle: i18nc("%1 is an graph name", "Do you want remove graph \"%1\" ?", graphName)

        standardButtons: Kirigami.Dialog.Cancel
        customFooterActions: [
            Kirigami.Action {
                text: i18n("Delete")
                icon.name: "edit-delete"
                onTriggered: {
                    root.removeItem(removePrompt.graphIndex);
                    root.graphs.splice(removePrompt.graphIndex, 1);
                    root.updateGraphsSetting();
                    removePrompt.close();
                }
            }
        ]

        /**
         * Open edit modal for specific graph
         * @param {number} index The graph index
         * @param {string} name The graph name
         */
        function openFor(index, name) {
            // Load settings page
            graphIndex = index;
            graphName = name;
            removePrompt.open();
        }
    }

    /*
     * utils functions
     */

    /**
     * Update graphs setting from js array
     */
    function updateGraphsSetting() {
        cfg_graphs = GraphFns.stringify(graphs);
    }

    /**
     * Add an new element
     * @param {string} type The graph type want to be added
     * @param {string} [device] The device want to be added (eg. gpu0)
     */
    function addGraph(type, device) {
        // Create graph item
        const item = GraphFns.create(type, device, Kirigami.Theme.defaultFont.pointSize);
        if (!item) {
            return;
        }

        // Custom behavior for text
        if (type == "text") {
            device = item.device;
        }

        // Add graph to lists
        graphs.push(item);
        graphs = graphs;
        root.addItem(item, availableGraphs.find(item.type, item.device ?? item.type));
        updateGraphsSetting();
    }
}
