import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.controls as KirigamiControls
import org.kde.kirigami.primitives as Primitives

Kirigami.Dialog {
    id: root

    property bool resetIndex: true

    property alias text: searchField.text

    property alias model: listView.model
    property alias delegate: listView.delegate
    property alias currentItem: listView.currentItem
    property alias section: listView.section
    property alias count: listView.count

    onOpened: {
        searchField.forceActiveFocus();
        searchField.text = "";
        if (resetIndex) {
            listView.currentIndex = 0;
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        KirigamiControls.SearchField {
            id: searchField

            Layout.fillWidth: true

            background: null

            Layout.margins: Platform.Units.smallSpacing

            Keys.onDownPressed: {
                const listViewHadFocus = listView.activeFocus;
                listView.forceActiveFocus();
                if (listView.currentIndex < listView.count - 1) {
                    // don't move to the next entry when we just changed focus from the search field to the list view
                    if (listViewHadFocus) {
                        listView.currentIndex++;
                    }
                } else {
                    listView.currentIndex = 0;
                }
            }
            Keys.onUpPressed: {
                listView.forceActiveFocus();
                if (listView.currentIndex === 0) {
                    listView.currentIndex = listView.count - 1;
                } else {
                    listView.currentIndex--;
                }
            }
            Keys.onPressed: event => {
                switch (event.key) {
                case Qt.Key_PageDown:
                    listView.forceActiveFocus();
                    listView.currentIndex = Math.min(listView.count - 1, listView.currentIndex + Math.floor(listView.height / listView.currentItem.height));
                    event.accepted = true;
                    break;
                case Qt.Key_PageUp:
                    listView.forceActiveFocus();
                    listView.currentIndex = Math.max(0, listView.currentIndex - Math.floor(listView.height / listView.currentItem.height));
                    event.accepted = true;
                    break;
                }
            }

            focusSequence: ""
            focusSequences: []
            autoAccept: false
        }

        Primitives.Separator {
            Layout.fillWidth: true
        }

        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Keys.forwardTo: searchField

            background: Rectangle {
                color: Platform.Theme.alternateBackgroundColor
            }

            ListView {
                id: listView

                currentIndex: count > 0 ? 0 : -1
                clip: height < contentHeight
                reuseItems: false
                Keys.forwardTo: searchField
                keyNavigationEnabled: true

                cacheBuffer: 10000

                KirigamiControls.PlaceholderMessage {
                    id: placeholder
                    anchors.centerIn: parent
                    width: parent.width - Platform.Units.gridUnit * 4
                    icon.name: 'system-search-symbolic'
                    visible: listView.count === 0 && text.length > 0
                    text: i18n("No result found.")
                }
            }
        }
    }

    function setCurrentIndex(index, scroll = true) {
        if (index < 0 || index > count) {
            listView.currentIndex = -1;
            return;
        }

        if (count > 0) {
            listView.currentIndex = index;

            if (scroll) {
                listView.positionViewAtIndex(index, ListView.Beginning);
            }
        } else {
            listView.currentIndex = -1;
        }
    }
}
