import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.plasmoid

SearchDialog {
    id: root
    resetIndex: false
    standardButtons: Kirigami.Dialog.NoButton
    title: i18nc("@title:window", "Choose application...")

    property alias sourceModel: sortModel.sourceModel
    property string currentUrl

    signal selected(var item)

    onCurrentUrlChanged: Qt.callLater(_updateCurrentIndex)
    onCountChanged: Qt.callLater(_updateCurrentIndex)
    function _updateCurrentIndex() {
        if (sortModel.count == 0 || count == 0) {
            return;
        }

        for (let i = 0; i < sortModel.count; i++) {
            const url = sortModel.data(sortModel.index(i, 0), 3 /* url */);
            if (url == currentUrl) {
                root.setCurrentIndex(i);
                break;
            }
        }
    }

    onTextChanged: {
        sortModel.filterString = text;
    }
    model: KItemModels.KSortFilterProxyModel {
        id: sortModel
        /**
         * Roles:
         * - 0: name
         * - 1: icon
         * - 2: group
         * - 3: url
         */

        filterRoleName: "name"
        filterCaseSensitivity: Qt.CaseInsensitive
    }

    section {
        property: "group"
        criteria: ViewSection.FirstCharacter
        delegate: Kirigami.ListSectionHeader {
            required property string section
            width: ListView.view.width
            text: section.toUpperCase()
        }
    }

    delegate: QQC2.ItemDelegate {
        id: item
        width: ListView.view.width

        required property var model
        property bool isCurrent: ListView.isCurrentItem

        onClicked: {
            root.currentUrl = model.url;
            root.selected(model);
            root.close();
        }

        contentItem: RowLayout {
            spacing: Kirigami.Units.smallSpacing

            // Content
            Kirigami.Icon {
                source: model.icon
                width: Kirigami.Units.iconSizes.medium
                height: width
            }
            QQC2.Label {
                Layout.fillWidth: true
                text: model.name
                textFormat: Text.PlainText
                elide: Text.ElideRight
                font.bold: item.isCurrent
            }
        }
    }
}
