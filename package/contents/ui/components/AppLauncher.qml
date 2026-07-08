import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.private.kicker as Kicker

Kicker.AppsModel {
    appletInterface: Plasmoid
    sorted: false

    function openUrl(url) {
        for (let i = 0; i < count; ++i) {
            const groupModel = modelForRow(i);
            for (let j = 0; j < groupModel.count; ++j) {
                const index = groupModel.index(j, 0);
                const itemUrl = groupModel.data(index, Qt.UserRole + 10 /* Kicker::UrlRole */)

                if (itemUrl == url) {
                  groupModel.trigger(j, "", null)
                }
            }
        }
    }
}
