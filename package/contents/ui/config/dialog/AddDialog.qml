import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kitemmodels as KItemModels
import org.kde.kirigami as Kirigami
import "../controls" as RMControls

RMControls.SearchDialog {
    id: root
    title: i18nc("@title:window", "Add graph")
    standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel

    property alias sourceModel: sortModel.sourceModel
    required property var graphs

    property var selectedItems: ({})
    signal selected(var items)

    onAccepted: {
        const items = [];
        Object.entries(selectedItems).forEach(([item, selected]) => {
            if (selected) {
                const [type, device] = item.split("::");
                items.push({
                    type,
                    device
                });
            }
        });

        selected(items);
    }

    onTextChanged: {
        sortModel.filterString = text;
    }
    model: KItemModels.KSortFilterProxyModel {
        id: sortModel
        filterRoleName: "name"
        filterCaseSensitivity: Qt.CaseInsensitive

        // filterRowCallback: row => {
        //     if (filterString == "") {
        //         return true;
        //     }
        //     const item = sourceModel.get(row);
        //     return item.name.toLowerCase().includes(filterString.toLowerCase());
        // }
    }

    section {
        property: "section"
        delegate: Kirigami.ListSectionHeader {
            required property string section
            width: ListView.view.width
            text: section
        }
    }

    delegate: QQC2.CheckDelegate {
        required property int index
        required property var model

        width: ListView.view.width

        // Disable when graph is already present
        enabled: !root.exist(model.type, model.device)
        checked: root.isSelected(model.type, model.device)
        text: model.name
        icon.source: model.icon

        onClicked: {
            if (enabled) {
                root.toggleSelection(model.type, model.device);
            }
        }

        contentItem: RowLayout {
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: model.icon
                fallback: model.fallbackIcon
                width: Kirigami.Units.iconSizes.small
                height: width
            }
            QQC2.Label {
                Layout.fillWidth: true
                text: model.name
                textFormat: Text.PlainText
                elide: Text.ElideRight

                opacity: enabled ? 1 : 0.6
            }
        }
    }

    function itemKey(type, device) {
        return String(type) + "::" + String(device ?? type);
    }
    function isSelected(type, device) {
        return selectedItems[itemKey(type, device)] ?? false;
    }
    function toggleSelection(type, device) {
        const key = itemKey(type, device);
        selectedItems[key] = !selectedItems[key] ?? true;
    }

    /**
     * Check if element of an specified device exist
     * @param {string} type The graph type want to be added
     * @param {string} device The graph device (device = type when not GPU or disk) want to be checked
     * @returns {boolean} The graph already exist or not
     */
    function exist(type, device) {
        // Text can be added multiple time
        if (type == "text") {
            return false;
        }

        for (const item of graphs) {
            if (item.type == type && (item.device ?? item.type) == device) {
                return true;
            }
        }
        return false;
    }
}
