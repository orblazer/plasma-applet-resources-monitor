import QtQuick 2.2
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: 'preferences-desktop-plasma'
        source: 'config/ConfigGeneral.qml'
    }
    ConfigCategory {
        name: i18n("Data")
        icon: 'preferences-desktop'
        source: 'config/ConfigData.qml'
    }
    ConfigCategory {
        name: i18n("Appearance")
        icon: 'preferences-desktop-color'
        source: 'config/ConfigAppearance.qml'
    }
}
