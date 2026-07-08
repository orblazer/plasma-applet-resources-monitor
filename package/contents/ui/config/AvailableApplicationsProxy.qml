import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.private.kicker as Kicker

ListModel {
    id: root
    signal loaded()

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

    property var _privateModel: Kicker.AppsModel {
        appletInterface: Plasmoid
        sorted: false

        property var sortOptions: ({
                numeric: true,
                sensitivity: "base"
            })

        Component.onCompleted: {
            const entries = [];
            for (let i = 0; i < count; ++i) {
                const groupModel = modelForRow(i);
                // Loop on applications
                for (let j = 0; j < groupModel.count; ++j) {
                    const index = groupModel.index(j, 0);

                    entries.push({
                        name: groupModel.data(index, Qt.DisplayRole),
                        icon: groupModel.data(index, Qt.DecorationRole),
                        group: groupModel.data(index, Qt.UserRole + 2 /* Kicker::GroupRole */),
                        url: groupModel.data(index, Qt.UserRole + 10 /* Kicker::UrlRole */),
                    });
                }
            }

            // Sort entries to group by group (letter) and alphabetic
            entries.sort((a, b) => {
                const byGroup = a.group.localeCompare(b.group, undefined, sortOptions);
                return byGroup || a.name.localeCompare(b.name, undefined, sortOptions);
            });
            for (const entry of entries) {
                root.append(entry);
            }

            root.loaded()
        }
    }
}
