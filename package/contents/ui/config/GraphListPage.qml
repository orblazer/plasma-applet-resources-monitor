import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCMUtils

KCMUtils.ScrollViewKCM {
    id: root
    // HACK: Provides footer separator
    extraFooterTopPadding: true

    property bool graphsUpgraded: false

    // Type = add | move{oldIndex:number,newIndex:number} | save | fix{index:number,name:string} | edit{index:number,name:string} | remove{index:number,name:string}
    signal action(string type, var payload)

    header: Kirigami.InlineMessage {
        visible: graphsUpgraded
        Layout.fillWidth: true
        text: i18n("The graphs as been upgraded to new version, please save it.")
    }

    view: ListView {
        id: graphsView
        clip: true // Avoid visual glitches
        focus: true // keyboard navigation
        activeFocusOnTab: true // keyboard navigation
        reuseItems: true
        currentIndex: -1 // No selection concept

        //? Use different array due to QML issue with deep object conversion
        model: ListModel {}

        delegate: Item { // External item required to make Kirigami.ListItemDragHandle work
            required property var index
            required property var model

            width: ListView.view.width
            implicitHeight: graphItem.implicitHeight

            QQC2.ItemDelegate {
                id: graphItem
                width: graphsView.width
                hoverEnabled: true
                // Stripes help the eye line up the text on the left and the button on the right
                Kirigami.Theme.useAlternateBackgroundColor: true

                down: false  // Disable press effect

                contentItem: RowLayout {
                    Kirigami.ListItemDragHandle {
                        listItem: graphItem
                        listView: graphsView

                        onMoveRequested: (oldIndex, newIndex) => {
                            graphsView.model.move(oldIndex, newIndex, 1);
                            root.action("move", {
                                oldIndex,
                                newIndex
                            });
                        }
                        onDropped: root.action("save", null)
                    }

                    // Content
                    Kirigami.Icon {
                        id: icon
                        source: model.icon
                        fallback: model.fallbackIcon
                        width: Kirigami.Units.iconSizes.smallMedium
                        height: width
                    }
                    QQC2.Label {
                        id: name
                        Layout.fillWidth: true
                        text: model.name
                        textFormat: Text.PlainText
                    }

                    // Actions
                    QQC2.Button {
                        id: fixButton
                        visible: model.needFix ?? false
                        text: i18n("Fix...")
                        QQC2.ToolTip.text: i18nc("@info:tooltip", "Edit \"%1\" graph", name.text)
                        QQC2.ToolTip.visible: hovered

                        onClicked: root.action("fix", {
                            index,
                            name: name.text
                        })
                    }
                    DelegateButton {
                        icon.name: "edit-entry-symbolic"
                        text: i18nc("@info:tooltip", "Edit \"%1\" graph", name.text)

                        onClicked: root.action("edit", {
                            index,
                            name: name.text
                        })
                    }
                    DelegateButton {
                        icon.name: "edit-delete"
                        text: i18nc("@info:tooltip", "Delete \"%1\" graph", name.text)

                        onClicked: root.action("remove", {
                            index,
                            name: name.text
                        })
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
            visible: graphsView.count === 0
            anchors.centerIn: parent
            width: parent.width - (Kirigami.Units.largeSpacing * 4)

            icon.name: "office-chart-line-stacked"
            text: i18n("No graph selected")
            explanation: i18nc("@info", "Click <i>%1</i> to get started", addButton.text)
        }
    }

    footer: RowLayout {
        spacing: Kirigami.Units.smallSpacing

        QQC2.Button {
            id: addButton

            text: i18n("Add graph…")
            icon.name: "list-add-symbolic"
            onClicked: root.action("add", null)
        }
    }

    // Action button
    component DelegateButton: QQC2.ToolButton {
        display: QQC2.AbstractButton.IconOnly
        QQC2.ToolTip.text: text
        QQC2.ToolTip.visible: hovered
    }

    /*
     * utils functions
     */

    /**
     * Add an new graph item
     * @param {object} graph The graph element
     * @param {object} [info] The graph info
     */
    function addItem(graph, info) {
        graphsView.model.append(_toElement(graph, info));
    }

    /**
     * Remove an element
     */
    function removeItem(index) {
        graphsView.model.remove(index, 1);
    }

    /**
     * Update an element info
     * @param {object} graph The graph element
     */
    function updateItem(graph) {
        for (let i = 0; i < graphsView.count; i++) {
            const item = graphsView.model.get(i);
            if (item.type === graph.type && item.device === graph.device) {
                graphsView.model.set(i, _toElement(item, graph));
                return;
            }
        }
    }

    /**
     * Set an element info at index
     * @param {object} index The graph element
     * @param {object} graph The graph element
     */
    function setItem(index, graph) {
        graphsView.model.set(index, _toElement(graph, graph));
    }

    /**
     * Convert an graph item to an view element
     * @param {object} graph The graph element
     * @param {object} [info] The graph info
     */
    function _toElement(graph, info) {
        if (typeof info === "undefined") {
            // Fallback info
            return {
                type: graph.type,
                name: `[${graph.type}${graph.device ? `:${graph.device}` : ""}]`,
                icon: "unknown",
                fallbackIcon: "unknown",
                section: "unknown",
                device: graph.device ?? graph.type,
                needFix: (graph.type === "gpu" || graph.type === "gpuText") && graph.device !== "all"
            };
        }
        if (graph.type == "text") {
            return Object.assign({}, info, {
                type: graph.type,
                name: i18nc("Chart name", "Text [%1]", graph.device),
                device: graph.device ?? graph.type,
                needFix: false
            });
        }
        return Object.assign({}, info, {
            type: graph.type,
            device: graph.device ?? graph.type,
            needFix: false
        });
    }
}
