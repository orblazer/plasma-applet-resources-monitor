import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kirigami.dialogs as KDialogs
import org.kde.plasma.extras as PlasmaExtras

Kirigami.Dialog {
    id: root
    standardButtons: Kirigami.Dialog.NoButton
    title: i18nc("@title:window", "Choose application...")

    required property ListModel model
    property string currentUrl

    signal selected(var item)

    ListModel {
        id: filteredModel

        function matches(item, text) {
            const filter = text.trim().toLowerCase();
            if (filter === "") {
                return true;
            }

            return item.name.toLowerCase().includes(filter);
        }

        function rebuildFilter() {
            const text = searchField.text;
            filteredModel.clear();

            let currentIndex = 0;
            for (let i = 0; i < root.model.count; ++i) {
                const item = root.model.get(i);
                if (matches(item, text)) {
                    if (item.url == root.currentUrl) {
                        currentIndex = filteredModel.count;
                    }

                    filteredModel.append({
                        name: item.name,
                        icon: item.icon,
                        group: item.group,
                        url: item.url
                    });
                }
            }

            if (filteredModel.count > 0) {
                listView.currentIndex = currentIndex;
                listView.positionViewAtIndex(currentIndex, ListView.Beginning);
            } else {
                listView.currentIndex = -1;
            }
        }
    }
    Connections {
        target: root.model
        function onLoaded() {
            filteredModel.rebuildFilter();
        }
    }
    onCurrentUrlChanged: {
        for (let i = 0; i < filteredModel.count; i++) {
            const item = filteredModel.get(i);
            if (item.url == currentUrl) {
                listView.currentIndex = i;
            }
        }
    }

    header: KDialogs.DialogHeader {
        dialog: root
        contentItem: ColumnLayout {
            KDialogs.DialogHeaderTopContent {
                dialog: root
            }

            Kirigami.SearchField {
                id: searchField
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.largeSpacing
                Layout.rightMargin: Kirigami.Units.largeSpacing
                Layout.bottomMargin: Kirigami.Units.largeSpacing
                placeholderText: i18n("Search...")

                onTextChanged: filteredModel.rebuildFilter()
            }
        }
    }

    ListView {
        id: listView
        clip: true
        reuseItems: true
        model: filteredModel
        height: Kirigami.Units.gridUnit * 30

        section {
            property: "group"
            delegate: Kirigami.ListSectionHeader {
                required property string section
                width: listView.width
                text: section
                visible: parent.visible
            }
        }

        delegate: QQC2.ItemDelegate {
            id: item
            width: ListView.view.width
            hoverEnabled: true
            property bool isCurrent: ListView.isCurrentItem

            onClicked: {
                root.currentUrl = model.url;
                root.selected(model);
                // root.close();
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

        // Animation
        highlightMoveDuration: Kirigami.Units.longDuration
        displaced: Transition {
            YAnimator {
                duration: Kirigami.Units.longDuration
            }
        }

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            width: parent.width - Kirigami.Units.gridUnit * 4
            visible: listView.count === 0
            text: i18n("No result.")
        }
    }
}
