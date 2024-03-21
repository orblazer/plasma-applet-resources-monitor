import QtQuick 2.15
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18nc("Config header", "General")
        icon: 'preferences-desktop-plasma'
        source: 'config/ConfigGeneral.qml'
    }
    ConfigCategory {
        name: i18nc("Config header", "Data")
        icon: 'preferences-desktop'
        source: 'config/ConfigData.qml'
    }
    ConfigCategory {
        name: i18nc("Config header", "Appearance")
        icon: 'preferences-desktop-color'
        source: 'config/ConfigAppearance.qml'
    }
}
