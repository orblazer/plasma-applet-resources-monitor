import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid
import "../components" as RMComponents

KCM.ScrollViewKCM {
    id: root
    // HACK: Provides footer separator
    extraFooterTopPadding: true

    readonly property int graphVersion: 1 //? Bump when some settings changes in "graphs" structure

    // Config properties
    property var cfg_graphs: "[]"
    property var graphs: JSON.parse(cfg_graphs) || [] // Parssed representation of "cfg_graphs"
    // TODO: handle "_v" changes

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
    property var cfg_clickAction
    property var cfg_clickActionCommand
    //#endregion

    // Uncomment for development
    /* Component.onCompleted: {
        addGraph("gpu", "all");
        addGraph("gpu", "gpu1");
        addGraph("network");
        addGraph("disk", "all");
        root.saveGraphs();
    } */

    // Graphs infos amd default values
    readonly property var graphDefaultValues: {
        "cpu": {
            "colors": ["highlightColor", "textColor", "textColor"],
            "sensorsType": ["usage", "clock", false],
            "thresholds": [85, 105],
            "clockAgregator": "average",
            "eCoresCount": ""
        },
        "memory": {
            "colors": ["highlightColor", "negativeTextColor"],
            "sensorsType": ["physical", "swap"],
            "thresholds": [70, 90]
        },
        "gpu": {
            "colors": ["highlightColor", "positiveTextColor", "textColor"],
            "sensorsType": ["memory", false],
            "thresholds": [70, 90]
            // "device" defined in "addGraph"
        },
        "network": {
            "colors": ["highlightColor", "positiveTextColor"],
            "sensorsType": [false, "kibibyte"],
            "uplimits": [100000, 100000],
            "ignoredInterfaces": []
        },
        "disk": {
            "colors": ["highlightColor", "positiveTextColor"],
            "sensorsType": [false],
            "uplimits": [200000, 200000]
            // "device" defined in "addGraph"
        }
    }

    // Retrieve available graphs
    AvailableGraphProxy {
        id: availableGraphs
    }

    // Content
    view: ListView {
        id: graphsView
        clip: true
        reuseItems: true

        //? Use differrent array due to QML issue with deep object conversion
        model: ListModel {
            Component.onCompleted: {
                Object.values(graphs).forEach(v => append({
                        type: v.type,
                        device: v.device ?? v.type
                    }));
            }
        }

        delegate: Item {
            // External item required to make Kirigami.ListItemDragHandle work
            readonly property var graphInfo: {
                const info = availableGraphs.find(model.type, model.device);
                if (typeof info === "undefined") { // Fallback info (mainly for development)
                    return {
                        type: model.type,
                        name: `[${model.type}${model.device ? `:${model.device}` : ""}]`,
                        icon: "unknown",
                        section: "unknown",
                        device: model.device ?? model.type
                    };
                }
                return info;
            }

            width: graphsView.width
            implicitHeight: graphItem.implicitHeight

            QQC2.ItemDelegate {
                id: graphItem
                width: graphsView.width
                hoverEnabled: true
                Kirigami.Theme.useAlternateBackgroundColor: Kirigami.Theme.alternateBackgroundColor

                down: false  // Disable press effect

                contentItem: RowLayout {
                    Kirigami.ListItemDragHandle {
                        listItem: graphItem
                        listView: graphsView

                        onMoveRequested: (oldIndex, newIndex) => {
                            graphsView.model.move(oldIndex, newIndex, 1);
                            root.graphs.splice(newIndex, 0, root.graphs.splice(oldIndex, 1)[0]);
                        }
                        onDropped: root.saveGraphs()
                    }

                    // Content
                    Kirigami.Icon {
                        source: graphInfo.icon
                        width: Kirigami.Units.iconSizes.smallMedium
                        height: width
                    }
                    QQC2.Label {
                        id: name
                        Layout.fillWidth: true
                        text: graphInfo.name
                        textFormat: Text.PlainText
                    }

                    // Actions
                    DelegateButton {
                        icon.name: "edit-entry-symbolic"
                        text: i18nc("@info:tooltip", "Edit \"%1\" graph", name.text)

                        onClicked: {
                            editDialog.openFor(index, name.text);
                        }
                    }
                    DelegateButton {
                        icon.name: "edit-delete"
                        text: i18nc("@info:tooltip", "Delete \"%1\" graph", name.text)

                        onClicked: {
                            removePrompt.graphIndex = index;
                            removePrompt.graphName = name.text;
                            removePrompt.open();
                        }
                    }
                }
            }
        }

        // Animation
        highlightMoveDuration: Kirigami.Units.longDuration
        displaced: Transition {
            YAnimator {
                duration: Kirigami.Units.longDuration
            }
        }

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            width: parent.width - (Kirigami.Units.largeSpacing * 4)
            visible: graphsView.count === 0

            icon.name: "office-chart-line-stacked"
            text: i18n("No graph selected")
            explanation: i18nc("@info", "Click <i>%1</i> to get started", addButton.text)
        }
    }

    footer: RowLayout {
        spacing: Kirigami.Units.smallSpacing

        QQC2.Button {
            id: addButton
            // HACK: Footer comes with margin
            Layout.leftMargin: Kirigami.Units.largeSpacing - 6

            text: i18n("Add graph…")
            icon.name: "list-add-symbolic"
            onClicked: addDialog.open()
        }
    }

    // Edit dialog
    Kirigami.Dialog {
        id: editDialog
        width: graphsView.width - Kirigami.Units.gridUnit * 4
        height: graphsView.height

        title: i18nc("@title:window", "Edit graph: %1", graphName)
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel

        property int graphIndex
        property string graphName

        property bool needSave: false
        onAccepted: {
            if (needSave) {
                graphs[graphIndex] = contentItem.item.item;
                saveGraphs();
            }
        }

        Loader {
            id: contentItem
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
            const source = `./parts/${filename}.qml`;

            // Load settings page
            graphIndex = index;
            graphName = name;
            contentItem.setSource(source, {
                item
            });
        }
    }

    // Add dialog
    Kirigami.Dialog {
        id: addDialog
        width: graphsView.width - Kirigami.Units.gridUnit * 4
        height: graphsView.height - Kirigami.Units.gridUnit * 4

        title: i18nc("@title:window", "Add graph")

        property bool needSave: false
        onClosed: needSave && root.saveGraphs()

        ListView {
            id: addGraphView
            clip: true
            reuseItems: true
            model: availableGraphs

            section {
                property: "section"
                delegate: Kirigami.ListSectionHeader {
                    required property string section
                    width: addGraphView.width
                    text: section
                }
            }

            delegate: Kirigami.SwipeListItem {
                width: addGraphView.width
                // Disable when graph is already present
                enabled: !root.graphExist(model.device)

                contentItem: RowLayout {
                    // Content
                    Kirigami.Icon {
                        source: model.icon
                        width: Kirigami.Units.iconSizes.smallMedium
                        height: width
                    }
                    QQC2.Label {
                        Layout.fillWidth: true
                        text: model.name
                        textFormat: Text.PlainText
                        elide: Text.ElideRight

                        opacity: enabled ? 1 : 0.6
                    }

                    // Actions
                    DelegateButton {
                        icon.name: "list-add-symbolic"
                        text: i18n("Add")
                        hoverEnabled: enabled

                        onClicked: {
                            addGraph(model.type, model.device);
                            addDialog.needSave = true;
                        }
                    }
                }
            }
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
                    graphsView.model.remove(removePrompt.graphIndex, 1);
                    root.graphs.splice(removePrompt.graphIndex, 1);
                    root.saveGraphs();
                    removePrompt.close();
                }
            }
        ]
    }

    // Action button
    component DelegateButton: QQC2.ToolButton {
        display: QQC2.AbstractButton.IconOnly
        QQC2.ToolTip.text: text
        QQC2.ToolTip.visible: hovered
    }

    // utils functions
    /**
     * Save graph changes
     */
    function saveGraphs() {
        cfg_graphs = JSON.stringify(graphs);
    }

    /**
     * Check if graph of an specified device exist
     * @param {string} value The graph device (device = type when not GPU or disk) want to be checked
     * @returns {boolean} The graph already exist or not
     */
    function graphExist(value) {
        for (let i = 0; i < graphsView.count; i++) {
            if (graphsView.model.get(i).device === value) {
                return true;
            }
        }
        return false;
    }

    /**
     * Add an new graph
     * @param {string} type The graph type want to be added
     * @param {string} [device] The device want to be added (eg. gpu0)
     */
    function addGraph(type, device) {
        // Retrieve default values and check if type is valid
        let defaultVals = graphDefaultValues[type];
        if (typeof defaultVals === "undefined") {
            return;
        }

        // Add constants (done manualy for have constatns at first)
        let item = {
            _v: graphVersion,
            type
        };
        //? Foreach due to can't use spredd in QML
        Object.entries(defaultVals).forEach(([k, v]) => item[k] = v);

        // Define "device" on "gpu" type
        if (type === "gpu" || type === "disk") {
            item.device = device;
        }

        // Add graph to lists
        graphs.push(item);
        graphsView.model.append({
            type,
            device: device ?? type
        });
    }
}
