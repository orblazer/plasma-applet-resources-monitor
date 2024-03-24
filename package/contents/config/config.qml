import QtQuick
import org.kde.plasma.configuration

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
