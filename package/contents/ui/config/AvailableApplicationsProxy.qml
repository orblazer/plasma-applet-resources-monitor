import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.private.kicker as Kicker

ListModel {
    id: root
    signal loaded

    function findByName(name) {
        for (let i = 0; i < count; i++) {
            const item = get(i);
            if (item.name.toLowerCase().includes(name.toLowerCase())) {
                return i;
            }
        }
        return -1;
    }
    function findByUrl(url) {
        for (let i = 0; i < count; i++) {
            const item = get(i);
            if (item.url == url) {
                return i;
            }
        }
        return -1;
    }

    property var _privateModel: Kicker.RootModel {
        appletInterface: Plasmoid
        flat: true
        sorted: true
        showTopLevelItems: true

        showAllApps: true
        showAllAppsCategorized: false
        showRecentApps: false
        showRecentDocs: false
        showPowerSession: false
        showFavoritesPlaceholder: false
        // showRootSeparator: true

        Component.onCompleted: {
            const entries = [];
            for (let i = 0; i < count; ++i) {
                const groupModel = modelForRow(i);
                if (groupModel?.description != "KICKER_ALL_MODEL") {
                    continue;
                }

                // Loop on applications
                for (let j = 0; j < groupModel.count; ++j) {
                    const index = groupModel.index(j, 0);

                    root.append({
                        name: groupModel.data(index, Qt.DisplayRole),
                        icon: groupModel.data(index, Qt.DecorationRole),
                        group: groupModel.data(index, Qt.UserRole + 2 /* Kicker::GroupRole */),
                        url: groupModel.data(index, Qt.UserRole + 10 /* Kicker::UrlRole */)
                    });
                }
            }

            root.loaded();
        }
    }
}
